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
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_types_controller.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_controller.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'guided_setup_controller.g.dart';

/// The ninety seconds between signing in and seeing a real number.
///
/// The app only starts making sense once a service type with a commission
/// exists and one service has been registered. Before that the home opens on a
/// zero and answers nothing. This does not explain the product — it makes the
/// product work, and then shows the user their own money.
@Riverpod(keepAlive: true)
class GuidedSetupController extends _$GuidedSetupController
    with BaseAsyncNotifier<GuidedSetupState> {
  ServiceTypeRepository get _serviceTypeRepository =>
      ref.read(serviceTypeRepositoryProvider);

  ServicesRepository get _servicesRepository =>
      ref.read(servicesRepositoryProvider);

  UserSettingsRepository get _userSettings =>
      ref.read(userSettingsRepositoryProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  TimeService get _timeService => ref.read(timeServiceProvider);

  /// When the setup opened, for the "time to first number" measurement whose
  /// target is under two minutes.
  DateTime? _startedAt;

  @override
  Future<GuidedSetupState> build() async {
    final userId = _authService.user?.uid ?? '';

    // Awaited, not read from `kaziDefaultCurrencyProvider`: that one answers
    // USD while it is still resolving, and everything seeded here is stamped
    // with whatever it says.
    //
    // `read`, not `watch`, and that is load-bearing: completing the setup runs
    // the currency migration, which invalidates this provider. Subscribed to
    // it, the controller would rebuild at that exact moment and throw away
    // every answer — dropping the user back on screen one instead of showing
    // them their first number. The currency is a starting value here, not a
    // live feed.
    final currency = await ref.read(kaziCurrencyControllerProvider.future);

    _startedAt = _timeService.now;
    unawaited(_analytics.log(AnalyticsEvent.setupStarted));

    // A stalled account can arrive with a catalog it built before giving up.
    // Loaded here so the catalog screen can show what they actually have
    // instead of a preset that will never be written over it.
    _existingTypes = await _loadExistingTypes(userId);

    return GuidedSetupState(
      status: BaseStateStatus.readyToUserInput,
      userId: userId,
      currency: currency,
    );
  }

  /// The types the account already had when the setup opened.
  List<ServiceType> _existingTypes = const [];

  Future<List<ServiceType>> _loadExistingTypes(String userId) async {
    if (userId.isEmpty) return const [];
    try {
      return await _serviceTypeRepository.get(userId);
    } catch (exception) {
      // Treated as "no catalog": the seed re-reads and re-checks before
      // writing anything, so the worst case here is showing a preset that the
      // seed then declines to write.
      Log.error(exception);
      return const [];
    }
  }

  GuidedSetupState? get _current => state.asData?.value;

  void _emit(GuidedSetupState next) => state = AsyncData(next);

  // ---------------------------------------------------------------- navigation

  void goToStep(SetupStep step) {
    final current = _current;
    if (current == null) return;
    _emit(current.copyWith(step: step));
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

  // ------------------------------------------------------------- step 1: work

  /// Picks a kit and seeds the catalog screen from it.
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

  /// Takes the profession the user typed when no kit matched, and moves to the
  /// employment question — which is how the commission gets answered without
  /// ever using the word.
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

    // The text itself is the research: the most frequent answers are the queue
    // of presets still to build.
    await _persistProfession(
      trimmed.isEmpty ? PresetCatalog.otherKey : trimmed,
    );

    // Stays on `profession`: with no preset and a typed answer, the page
    // renders the employment question, which is how this path reaches a
    // commission. Only that screen moves on to the catalog.
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
        // Nothing is custom yet on this path, so the whole list follows.
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

    // Saved as soon as it is answered, not at the end: someone who abandons
    // midway keeps what they already told us.
    try {
      await _userSettings.setProfession(current.userId, profession);
    } catch (exception) {
      // Not worth stopping the setup over — the answer is only used to pick
      // presets, which already happened in memory.
      Log.error(exception);
    }
  }

  /// The catalog screen's starting list.
  ///
  /// An account that already has types gets those, not the kit: the seed
  /// refuses to write over an existing catalog, so offering a preset there
  /// would be a screen whose every tap is discarded — and the first-service
  /// screen would have no real type to point at.
  List<SetupCatalogItem> _itemsFrom(
    ProfessionPreset? preset,
    SupportedCurrency currency,
  ) {
    if (_existingTypes.isNotEmpty) {
      return [
        for (final type in _existingTypes)
          SetupCatalogItem(
            id: type.id,
            existingTypeId: type.id,
            name: type.name,
            value: type.defaultValue,
            // Null means "never configured", which the setup's job is to turn
            // into a real number — the kit's default is the better guess.
            commissionPercent:
                type.effectiveCommissionPercent ??
                preset?.defaultCommissionPercent ??
                PresetCatalog.selfEmployedCommissionPercent,
            hasCustomCommission: type.effectiveCommissionPercent != null,
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

  // ---------------------------------------------------------- step 2: catalog

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

  /// Applies an inline edit from the price sheet. A blank price is allowed and
  /// stays blank — it is asked for again when the service is registered.
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

  /// Adds a service the user typed, on either path.
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

  // ------------------------------------------------------- step 3: commission

  /// One percentage for everything, which is the common case. Items the user
  /// singled out keep their own.
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

  // ------------------------------------------------------------ step 4: cycle

  void setBillingCycle(BillingCycle cycle) {
    final current = _current;
    if (current == null) return;
    _emit(current.copyWith(billingCycle: cycle));
  }

  void setCurrency(SupportedCurrency currency) {
    final current = _current;
    if (current == null) return;

    // Prices are seeded in BRL only, so switching away from it has to drop
    // them rather than relabel Brazilian amounts with another symbol.
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

  // ---------------------------------------------------- step 5: first service

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

  // --------------------------------------------------------------- completion

  /// Writes everything the setup collected, in the one order that is safe.
  ///
  /// The stamp that closes the gate goes **last**: if any step before it fails,
  /// the flag stays unset, the setup comes back on the next launch, and the
  /// catalog it already wrote is detected and left alone.
  Future<void> complete({required bool registerService}) async {
    final current = _current;
    if (current == null || current.userId.isEmpty) return;

    _emit(current.copyWith(status: BaseStateStatus.loading));

    try {
      final seeded = await _seedCatalog(current);
      final registered = registerService
          ? await _registerFirstService(current, seeded)
          : null;

      // Reuses the migration rather than writing the currency by hand. It does
      // exactly the right sequence — set currency, backfill legacy documents,
      // stamp `currencyMigratedAt` last — and skipping it would leave that
      // stamp unset, which drops the user straight into the blocking migration
      // screen the moment this setup ends.
      //
      // For a brand-new account the backfill finds nothing and this is close to
      // free; for a stalled one it is the whole point, since the service they
      // registered months ago predates currencies and has to be labelled.
      await _confirmCurrency(current);

      await _userSettings.setBillingCycle(current.userId, current.billingCycle);

      // Only now: everything above is replayable, and this is what stops it
      // being replayed.
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

  /// Runs the currency migration for the answer given on the cycle screen, and
  /// refuses to continue if it did not land.
  ///
  /// `confirm` reports failure through its own state rather than by throwing,
  /// and [CurrencyMigrationState.isRequired] counts `error` as "still
  /// required". Left unchecked, a failed write here would be invisible until
  /// the moment the setup stamps itself complete — at which point the router
  /// opens the gate, sees the migration still pending, and throws the user
  /// onto the blocking migration screen instead of the number they just
  /// earned. Better to fail here, where the step can simply be retried.
  Future<void> _confirmCurrency(GuidedSetupState current) async {
    final migration = ref.read(currencyMigrationControllerProvider.notifier);
    await migration.confirm(current.currency);

    final result = ref.read(currencyMigrationControllerProvider);
    if (result.status == CurrencyMigrationStatus.done) return;

    throw ExternalError(
      result.errorMessage ?? KaziLocalizations.current.errorToMigrateCurrency,
    );
  }

  /// Writes the chosen catalog, but only into an account that has none.
  ///
  /// The count is re-read here rather than trusted from startup: this is the
  /// guard that keeps a stalled user's existing catalog from being buried under
  /// a preset. Their own service, if they have one, is never touched.
  Future<List<ServiceType>> _seedCatalog(GuidedSetupState current) async {
    final existing = await _serviceTypeRepository.get(current.userId);
    if (existing.isNotEmpty) return _applyEditsTo(existing, current);

    final toSeed = [
      for (final item in current.selectedItems)
        ServiceType(
          userId: current.userId,
          name: item.name,
          defaultValue: item.value,
          commissionPercent: item.commissionPercent,
          currency: current.currency.isoCode,
          color: KaziHexColor.encode(
            // Same six marks in both brightnesses, so no BuildContext is
            // needed to pick one.
            KaziColors.light.category(current.items.indexOf(item)),
          ),
        ),
    ];

    // One batch, and deliberately not through `FreemiumGuard`: seeding is not
    // the user adding something, and the free ceiling is set above the largest
    // preset so nobody is born over their own limit. It also never touches
    // `CreationAdCoordinator` — eight counted creations would fire an
    // interstitial in the middle of the setup.
    return _serviceTypeRepository.addAll(toSeed);
  }

  /// Writes back the prices and commissions the user adjusted on a catalog the
  /// account already had.
  ///
  /// The seed refuses to create anything here, but the screens are still real:
  /// someone who retypes a price or sets a commission has to see it stick, and
  /// filling in a missing commission is the single most valuable thing this
  /// path does — an unconfigured one is what makes the home understate their
  /// earnings.
  Future<List<ServiceType>> _applyEditsTo(
    List<ServiceType> existing,
    GuidedSetupState current,
  ) async {
    final result = <ServiceType>[];

    for (final type in existing) {
      final item = _firstOrNull(
        current.items,
        (each) => each.existingTypeId == type.id,
      );

      final unchanged =
          item == null ||
          (item.name == type.name &&
              item.value == type.defaultValue &&
              item.commissionPercent == type.effectiveCommissionPercent);

      if (unchanged) {
        result.add(type);
        continue;
      }

      final updated = type.copyWith(
        name: item.name,
        defaultValue: item.value,
        commissionPercent: item.commissionPercent,
      );

      try {
        await _serviceTypeRepository.update(updated);
        result.add(updated);
      } catch (exception) {
        // One line failing to save is not worth losing the whole setup over;
        // the rest of the catalog and the first service still go through.
        Log.error(exception);
        result.add(type);
      }
    }

    return result;
  }

  Future<Service?> _registerFirstService(
    GuidedSetupState current,
    List<ServiceType> seeded,
  ) async {
    final itemId = current.firstServiceItemId;
    if (itemId == null) return null;

    final item = _firstOrNull(current.items, (each) => each.id == itemId);
    if (item == null) return null;

    // Matched by name because the seed only just assigned the ids, and the
    // catalog screen forbids duplicate names for exactly this reason.
    final type = _firstOrNull(seeded, (each) => each.name == item.name);
    if (type == null) return null;

    final value = item.value;
    if (value == null || value <= 0) return null;

    final date = current.firstServiceDate ?? _timeService.now;
    final service = Service(
      userId: current.userId,
      typeId: type.id,
      type: type,
      value: value,
      commissionPercent: item.commissionPercent,
      currency: current.currency.isoCode,
      rateDate: await _resolveRateDate(date),
      date: date,
    );

    final created = await _servicesRepository.add(service);
    return created.isEmpty ? service : created.first;
  }

  /// Anchors the service to a day the rate history knows about, mirroring what
  /// the service form does. A failure here degrades to the service's own day
  /// rather than blocking the save — no service ever fails to save over rates.
  Future<String> _resolveRateDate(DateTime date) async {
    try {
      final history = await ref.read(exchangeRateHistoryServiceProvider.future);
      return history.resolveDateKey(date);
    } catch (exception) {
      Log.error(exception);
      return ExchangeRates.dateKeyOf(date);
    }
  }

  /// The home and the service screens were built against an empty account.
  void _refreshServiceScreens() {
    ref.invalidate(serviceTypesControllerProvider);
    ref.invalidate(serviceLandingControllerProvider);
  }

  /// Leaves the setup without finishing it. Whatever was answered is kept and
  /// the person is not asked again — the home checklist picks it up.
  Future<void> exit() async {
    final current = _current;
    unawaited(
      _analytics.log(
        AnalyticsEvent.setupExited,
        parameters: {'step': (current?.step ?? SetupStep.profession).name},
      ),
    );
    await ref.read(onboardingControllerProvider.notifier).markSkipped();
  }

  /// `package:collection` is not a dependency of this app, and one lookup does
  /// not justify making it one.
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
