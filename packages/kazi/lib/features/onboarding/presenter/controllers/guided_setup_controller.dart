import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/onboarding/domain/models/profession_preset.dart';
import 'package:kazi/features/onboarding/domain/models/setup_catalog_item.dart';
import 'package:kazi/features/onboarding/domain/preset_catalog.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_controller.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'guided_setup_controller.g.dart';

/// Drives the five-step setup that seeds a catalog and registers a first
/// service. Write order, idempotency and the stalled-account rules are in
/// `features/onboarding/README.md`.
@Riverpod(keepAlive: true)
class GuidedSetupController extends _$GuidedSetupController
    with BaseAsyncNotifier<GuidedSetupState> {
  CatalogItemRepository get _catalogItemRepository =>
      ref.read(catalogItemRepositoryProvider);

  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  UserSettingsRepository get _userSettings =>
      ref.read(userSettingsRepositoryProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  TimeService get _timeService => ref.read(timeServiceProvider);

  DateTime? _startedAt;

  @override
  Future<GuidedSetupState> build() async {
    final userId = _authService.user?.uid ?? '';

    // Awaited and `read`, never `watch`: watching would rebuild the controller
    // mid-completion and discard every answer. See README.md.
    final currency = await ref.read(kaziCurrencyControllerProvider.future);

    _startedAt = _timeService.now;
    unawaited(_analytics.log(AnalyticsEvent.setupStarted));

    _existingItems = await _loadExistingTypes(userId);

    return GuidedSetupState(
      status: BaseStateStatus.readyToUserInput,
      userId: userId,
      currency: currency,
    );
  }

  List<CatalogItem> _existingItems = const [];

  Future<List<CatalogItem>> _loadExistingTypes(String userId) async {
    if (userId.isEmpty) return const [];
    try {
      return await _catalogItemRepository.get(userId);
    } catch (exception) {
      // Treated as "no catalog"; the seed re-reads before writing anything.
      Log.error(exception);
      return const [];
    }
  }

  GuidedSetupState? get _current => state.asData?.value;

  void _emit(GuidedSetupState next) => state = AsyncData(next);

  // Navigation

  DateTime? _stepEnteredAt;

  int? get _secondsOnStep {
    final enteredAt = _stepEnteredAt;
    if (enteredAt == null) return null;
    return _timeService.now.difference(enteredAt).inSeconds;
  }

  void goToStep(SetupStep step) {
    final current = _current;
    if (current == null) return;
    _emit(current.copyWith(step: step));
    _stepEnteredAt = _timeService.now;
    unawaited(
      _analytics.log(
        AnalyticsEvent.setupStepViewed,
        parameters: {'step': step.name},
      ),
    );
  }

  void back() {
    final current = _current;
    if (current == null || current.step.index == 0) return;
    goToStep(SetupStep.values[current.step.index - 1]);
  }

  // Step 1: work

  Future<void> chooseProfession(ProfessionPreset preset) async {
    final current = _current;
    if (current == null) return;

    _emit(
      current.copyWith(
        preset: () => preset,
        customProfession: '',
        items: _itemsFrom(preset, current.currency),
      ),
    );

    await _persistProfession(preset.key);
    goToStep(SetupStep.catalog);
  }

  /// Stays on [SetupStep.profession]: with no preset and a typed answer the
  /// page renders the employment question, which is what sets the commission.
  Future<void> chooseCustomProfession(String typed) async {
    final current = _current;
    if (current == null) return;

    final trimmed = typed.trim();
    _emit(
      current.copyWith(
        preset: () => null,
        customProfession: trimmed,
        items: _itemsFrom(null, current.currency),
      ),
    );

    await _persistProfession(
      trimmed.isEmpty ? PresetCatalog.otherKey : trimmed,
    );
  }

  void setSelfEmployed({required bool isSelfEmployed}) {
    final current = _current;
    if (current == null) return;

    final commission = isSelfEmployed
        ? PresetCatalog.selfEmployedCommissionPercent
        : PresetCatalog.employedCommissionPercent;

    _emit(
      current.copyWith(
        isSelfEmployed: isSelfEmployed,
        items: [
          for (final item in current.items)
            item.hasCustomCommission
                ? item
                : item.copyWith(commissionPercent: commission),
        ],
      ),
    );
  }

  Future<void> _persistProfession(String profession) async {
    final current = _current;
    if (current == null || current.userId.isEmpty) return;

    // Persisted per answer, not at the end, so an abandoned setup keeps it.
    try {
      await _userSettings.setProfession(current.userId, profession);
    } catch (exception) {
      // Only used to pick presets, which already happened in memory.
      Log.error(exception);
    }
  }

  /// The catalog screen's starting list: the account's own items when it has
  /// any, since the seed refuses to write over an existing catalog.
  List<SetupCatalogItem> _itemsFrom(
    ProfessionPreset? preset,
    SupportedCurrency currency,
  ) {
    if (_existingItems.isNotEmpty) {
      return [
        for (final saved in _existingItems)
          SetupCatalogItem(
            id: saved.id,
            existingItemId: saved.id,
            name: saved.name,
            value: saved.defaultValue,
            // Null means "never configured": fall back to the kit's default.
            commissionPercent:
                saved.effectiveCommissionPercent ??
                preset?.defaultCommissionPercent ??
                PresetCatalog.selfEmployedCommissionPercent,
            hasCustomCommission: saved.effectiveCommissionPercent != null,
          ),
      ];
    }

    if (preset == null) return const [];

    return [
      for (final (index, service) in preset.services.indexed)
        SetupCatalogItem(
          id: '${preset.key}_$index',
          name: service.label(),
          value: preset.priceFor(service, currency),
          commissionPercent: preset.defaultCommissionPercent,
          selected: service.preSelected,
        ),
    ];
  }

  // Step 2: catalog

  void toggleItem(String id) {
    final current = _current;
    if (current == null) return;
    _emit(
      current.copyWith(
        items: [
          for (final item in current.items)
            item.id == id ? item.copyWith(selected: !item.selected) : item,
        ],
      ),
    );
  }

  /// A blank price is allowed and stays blank; it is asked for again when the
  /// service is registered.
  void editItem(String id, {required String name, double? value}) {
    final current = _current;
    if (current == null) return;
    _emit(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.id == id)
              item.copyWith(name: name.trim(), value: () => value)
            else
              item,
        ],
      ),
    );
  }

  void addItem({required String name, double? value}) {
    final current = _current;
    if (current == null) return;

    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final commission = current.preset?.defaultCommissionPercent ??
        (current.isSelfEmployed
            ? PresetCatalog.selfEmployedCommissionPercent
            : PresetCatalog.employedCommissionPercent);

    _emit(
      current.copyWith(
        items: [
          ...current.items,
          SetupCatalogItem(
            id: 'typed_${current.items.length}_${_timeService.now.microsecondsSinceEpoch}',
            name: trimmed,
            value: value,
            commissionPercent: commission,
          ),
        ],
      ),
    );
  }

  void removeItem(String id) {
    final current = _current;
    if (current == null) return;
    _emit(
      current.copyWith(
        items: current.items.where((item) => item.id != id).toList(),
      ),
    );
  }

  // Step 3: commission

  /// Applies one percentage to every item except those given their own.
  void setCommissionForAll(double percent) {
    final current = _current;
    if (current == null) return;
    _emit(
      current.copyWith(
        items: [
          for (final item in current.items)
            item.hasCustomCommission
                ? item
                : item.copyWith(commissionPercent: percent),
        ],
      ),
    );
  }

  void setCommissionFor(String id, double percent) {
    final current = _current;
    if (current == null) return;
    _emit(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.id == id)
              item.copyWith(
                commissionPercent: percent,
                hasCustomCommission: true,
              )
            else
              item,
        ],
      ),
    );
  }

  // Step 4: cycle

  void setBillingCycle(BillingCycle cycle) {
    final current = _current;
    if (current == null) return;
    _emit(current.copyWith(billingCycle: cycle));
  }

  void setCurrency(SupportedCurrency currency) {
    final current = _current;
    if (current == null) return;

    // Preset prices are authored in BRL only, so switching away drops them
    // rather than relabelling Brazilian amounts. See README.md.
    final keepsPrices = currency == SupportedCurrency.brl;
    _emit(
      current.copyWith(
        currency: currency,
        items: keepsPrices
            ? current.items
            : [for (final item in current.items) item.copyWith(value: () => null)],
      ),
    );
  }

  // Step 5: first service

  void chooseFirstService(String itemId) {
    final current = _current;
    if (current == null) return;
    _emit(current.copyWith(firstServiceItemId: () => itemId));
  }

  void chooseFirstServiceDate(DateTime date) {
    final current = _current;
    if (current == null) return;
    _emit(current.copyWith(firstServiceDate: () => date));
  }

  // Completion

  /// Writes everything the setup collected. The order is load-bearing and the
  /// completion stamp goes last — see README.md.
  Future<void> complete({required bool registerService}) async {
    final current = _current;
    if (current == null || current.userId.isEmpty) return;

    _emit(current.copyWith(status: BaseStateStatus.loading));

    try {
      final seeded = await _seedCatalog(current);
      final registered = registerService
          ? await _registerFirstService(current, seeded)
          : null;

      await _confirmCurrency(current);

      await _userSettings.setBillingCycle(current.userId, current.billingCycle);

      // Last: everything above is replayable, and this is what stops the replay.
      await ref.read(onboardingControllerProvider.notifier).markCompleted();

      unawaited(
        _analytics.log(
          AnalyticsEvent.setupCompleted,
          parameters: {
            'seconds': _elapsedSeconds,
            'seeded_types': seeded.length,
            'registered_service': registered != null,
            'profession': current.professionKey,
          },
        ),
      );

      _refreshServiceScreens();

      _emit(
        current.copyWith(
          status: BaseStateStatus.success,
          step: SetupStep.result,
          registeredValue: registered?.value,
          registeredCommission: registered?.commissionValue,
        ),
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Runs the currency migration for the answer given on the cycle screen.
  ///
  /// `confirm` reports failure through its state rather than by throwing, so
  /// the state is inspected and rethrown here — an unchecked failure would only
  /// surface after [complete] stamps itself done. See README.md.
  Future<void> _confirmCurrency(GuidedSetupState current) async {
    final migration = ref.read(currencyMigrationControllerProvider.notifier);
    await migration.confirm(current.currency);

    final result = ref.read(currencyMigrationControllerProvider);
    if (result.status == CurrencyMigrationStatus.done) return;

    throw ExternalError(
      result.errorMessage ?? KaziLocalizations.current.errorToMigrateCurrency,
    );
  }

  /// Writes the chosen catalog, but only into an account that has none. The
  /// count is re-read here rather than trusted from startup — this is the guard
  /// against burying a stalled user's catalog under a preset.
  Future<List<CatalogItem>> _seedCatalog(GuidedSetupState current) async {
    final existing = await _catalogItemRepository.get(current.userId);
    if (existing.isNotEmpty) return _applyEditsTo(existing, current);

    final toSeed = [
      for (final item in current.selectedItems)
        CatalogItem(
          userId: current.userId,
          name: item.name,
          defaultValue: item.value,
          commissionPercent: item.commissionPercent,
          currency: current.currency.isoCode,
          color: KaziHexColor.encode(
            // Same six marks in both brightnesses, so no BuildContext needed.
            KaziColors.light.category(current.items.indexOf(item)),
          ),
        ),
    ];

    // Deliberately bypasses FreemiumGuard and CreationAdCoordinator; see
    // README.md.
    return _catalogItemRepository.addAll(toSeed);
  }

  /// Writes back the prices and commissions the user adjusted on a catalog the
  /// account already had.
  Future<List<CatalogItem>> _applyEditsTo(
    List<CatalogItem> existing,
    GuidedSetupState current,
  ) async {
    final result = <CatalogItem>[];

    for (final saved in existing) {
      final item = _firstOrNull(
        current.items,
        (each) => each.existingItemId == saved.id,
      );

      final unchanged =
          item == null ||
          (item.name == saved.name &&
              item.value == saved.defaultValue &&
              item.commissionPercent == saved.effectiveCommissionPercent);

      if (unchanged) {
        result.add(saved);
        continue;
      }

      final updated = saved.copyWith(
        name: item.name,
        defaultValue: item.value,
        commissionPercent: item.commissionPercent,
      );

      try {
        await _catalogItemRepository.update(updated);
        result.add(updated);
      } catch (exception) {
        // One row failing does not abort the setup; the rest still go through.
        Log.error(exception);
        result.add(saved);
      }
    }

    return result;
  }

  Future<Service?> _registerFirstService(
    GuidedSetupState current,
    List<CatalogItem> seeded,
  ) async {
    final itemId = current.firstServiceItemId;
    if (itemId == null) return null;

    final item = _firstOrNull(current.items, (each) => each.id == itemId);
    if (item == null) return null;

    // Matched by name because the seed only just assigned the ids; the catalog
    // screen forbids duplicate names for exactly this reason.
    final catalogItem = _firstOrNull(seeded, (each) => each.name == item.name);
    if (catalogItem == null) return null;

    final value = item.value;
    if (value == null || value <= 0) return null;

    final date = current.firstServiceDate ?? _timeService.now;
    final service = Service(
      userId: current.userId,
      catalogItemId: catalogItem.id,
      catalogItem: catalogItem,
      value: value,
      commissionPercent: item.commissionPercent,
      currency: current.currency.isoCode,
      rateDate: await _resolveRateDate(date),
      date: date,
    );

    final created = await _servicesRepository.add(service);
    return created.isEmpty ? service : created.first;
  }

  /// Anchors the service to a day the rate history knows about. Failure
  /// degrades to the service's own day — no save ever fails over rates.
  Future<String> _resolveRateDate(DateTime date) async {
    try {
      final history = await ref.read(exchangeRateHistoryServiceProvider.future);
      return history.resolveDateKey(date);
    } catch (exception) {
      Log.error(exception);
      return ExchangeRates.dateKeyOf(date);
    }
  }

  /// The home and service screens were built against an empty account.
  void _refreshServiceScreens() {
    ref.invalidate(catalogControllerProvider);
    ref.invalidate(serviceLandingControllerProvider);
  }

  /// Leaves without finishing. Answers are kept and the user is not asked
  /// again; the home checklist picks it up.
  Future<void> exit() async {
    final current = _current;
    unawaited(
      _analytics.log(
        AnalyticsEvent.setupExited,
        parameters: {
          'step': (current?.step ?? SetupStep.profession).name,
          if (_secondsOnStep case final int seconds) 'seconds_on_step': seconds,
        },
      ),
    );
    await ref.read(onboardingControllerProvider.notifier).markSkipped();
  }

  static T? _firstOrNull<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  int get _elapsedSeconds {
    final startedAt = _startedAt;
    if (startedAt == null) return 0;
    return _timeService.now.difference(startedAt).inSeconds;
  }
}
