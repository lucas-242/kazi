import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'currency_migration_controller.g.dart';

/// Applies the currency confirmed in the guided setup as the default, and
/// stamps it onto every service registered before multi-currency support.
///
/// Without it there is no way to tell a service worth 100 BRL from one worth
/// 100 USD, and every total the app shows is a sum of unlike quantities.
@Riverpod(keepAlive: true)
class CurrencyMigrationController extends _$CurrencyMigrationController {
  UserSettingsRepository get _userSettings =>
      ref.read(userSettingsRepositoryProvider);

  CurrencyMigrationRepository get _migration =>
      ref.read(currencyMigrationRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  @override
  CurrencyMigrationState build() => const CurrencyMigrationState();

  /// `currencyMigratedAt` is written **last**: if anything fails midway the
  /// flag stays unset, the setup comes back, and the already-updated documents
  /// are skipped on the retry.
  Future<void> confirm(SupportedCurrency currency) async {
    final userId = _authService.user?.uid;
    if (userId == null) return;

    state = state.copyWith(status: CurrencyMigrationStatus.applying);

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

  /// How much data the backfill actually touched, bucketed. It separates
  /// "confirmed a currency for two services" from "waited while four hundred
  /// were rewritten" — very different experiences of the same step.
  static String _bucket(int migrated) => switch (migrated) {
    0 => '0',
    < 10 => '1-9',
    < 50 => '10-49',
    < 200 => '50-199',
    _ => '200+',
  };
}
