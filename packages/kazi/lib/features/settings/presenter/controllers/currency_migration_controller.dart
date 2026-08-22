import 'dart:async';
import 'dart:ui';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'currency_migration_controller.g.dart';

/// Asks users who registered services before multi-currency support which
/// currency those amounts were in, then stamps the answer onto them.
///
/// Without it there is no way to tell a service worth 100 BRL from one worth
/// 100 USD, and every total the app shows is a sum of unlike quantities.
@Riverpod(keepAlive: true)
class CurrencyMigrationController extends _$CurrencyMigrationController {
  UserSettingsRepository get _userSettings =>
      ref.read(userSettingsRepositoryProvider);

  CurrencyMigrationRepository get _migration =>
      ref.read(currencyMigrationRepositoryProvider);

  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  CatalogItemRepository get _catalogItemRepository =>
      ref.read(catalogItemRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  @override
  CurrencyMigrationState build() => const CurrencyMigrationState();

  /// Decides whether the gate has to open. Fail-open: if the check itself
  /// fails, the user gets into the app rather than being locked out by a
  /// network blip — the gate simply reappears next launch.
  Future<void> check() async {
    final userId = _authService.user?.uid;
    if (userId == null) {
      state = const CurrencyMigrationState();
      return;
    }

    try {
      final settings = await _userSettings.get(userId);

      if (settings.hasMigratedCurrency) {
        state = state.copyWith(status: CurrencyMigrationStatus.done);
        return;
      }

      final serviceCount = await _servicesRepository.count(userId);
      final itemCount = (await _catalogItemRepository.get(userId)).length;

      // Nothing to reinterpret: seed the device guess and never bother them.
      if (serviceCount == 0 && itemCount == 0) {
        await _completeSilently(userId);
        return;
      }

      state = state.copyWith(
        status: CurrencyMigrationStatus.required,
        suggestedCurrency: settings.defaultCurrency ?? _deviceCurrency,
        affectedServices: serviceCount,
      );

      // A blocking screen between an existing user and their data. If people
      // stall or leave here, it does not show up anywhere else — the router
      // simply keeps them on it.
      unawaited(_analytics.log(AnalyticsEvent.currencyMigrationShown));
    } catch (exception) {
      Log.error(exception);
      state = state.copyWith(status: CurrencyMigrationStatus.done);
    }
  }

  /// Applies [currency] as the default and backfills the legacy documents.
  ///
  /// `currencyMigratedAt` is written **last**: if anything fails midway the
  /// flag stays unset, the gate comes back, and the already-updated documents
  /// are skipped on the retry.
  Future<void> confirm(SupportedCurrency currency) async {
    final userId = _authService.user?.uid;
    if (userId == null) return;

    state = state.copyWith(
      status: CurrencyMigrationStatus.applying,
      suggestedCurrency: currency,
    );

    try {
      // Written straight to the authoritative store rather than through
      // KaziCurrencyController, so the migration cannot be derailed by a
      // local-cache write. The controller is refreshed from it below.
      await _userSettings.setDefaultCurrency(userId, currency);

      final migrated = await _migration.backfillCurrency(userId, currency);
      await _userSettings.markCurrencyMigrated(userId, migrated: migrated);

      ref.invalidate(kaziCurrencyControllerProvider);
      unawaited(
        _analytics.log(
          AnalyticsEvent.currencyMigrationConfirmed,
          parameters: {
            'currency': currency.name,
            'backfilled_bucket': _bucket(migrated),
          },
        ),
      );
      state = state.copyWith(status: CurrencyMigrationStatus.done);
    } on AppError catch (exception) {
      _reportFailure(exception);
      state = state.copyWith(
        status: CurrencyMigrationStatus.error,
        errorMessage: exception.message,
      );
    } catch (exception) {
      _reportFailure(exception);
      Log.error(exception);
      state = state.copyWith(
        status: CurrencyMigrationStatus.error,
        errorMessage: KaziLocalizations.current.errorToMigrateCurrency,
      );
    }
  }

  Future<void> _completeSilently(String userId) async {
    try {
      await _userSettings.setDefaultCurrency(userId, _deviceCurrency);
      await _userSettings.markCurrencyMigrated(userId, migrated: 0);
    } catch (exception) {
      // Not worth blocking a brand-new user over; the check runs again next
      // launch and there is nothing to lose meanwhile.
      Log.error(exception);
    }

    state = state.copyWith(status: CurrencyMigrationStatus.done);
  }

  SupportedCurrency get _deviceCurrency => KaziCurrencyManager.deviceDefault(
    PlatformDispatcher.instance.locale.countryCode ?? '',
  );

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  /// The error's class, never its message: the message is localized, and this
  /// one is worth grouping across the three languages the app speaks.
  void _reportFailure(Object exception) {
    unawaited(
      _analytics.log(
        AnalyticsEvent.currencyMigrationFailed,
        parameters: {'reason': exception.runtimeType.toString()},
      ),
    );
  }

  /// How much data the migration actually touched, bucketed. It separates
  /// "answered a question about two services" from "waited while four hundred
  /// were rewritten" — which are very different experiences of the same screen.
  static String _bucket(int migrated) => switch (migrated) {
    0 => '0',
    < 10 => '1-9',
    < 50 => '10-49',
    < 200 => '50-199',
    _ => '200+',
  };
}
