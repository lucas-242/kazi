import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/interstitial_ad_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/onboarding/domain/preset_catalog.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'guided_setup_controller_test.mocks.dart';

@GenerateMocks([
  UserSettingsRepository,
  CurrencyMigrationRepository,
  ServicesRepository,
  ServiceTypeRepository,
  AuthService,
  AnalyticsService,
  TimeService,
  InterstitialAdService,
])
void main() {
  late MockUserSettingsRepository userSettings;
  late MockCurrencyMigrationRepository migrationRepository;
  late MockServicesRepository servicesRepository;
  late MockServiceTypeRepository serviceTypeRepository;
  late MockAuthService authService;
  late MockAnalyticsService analytics;
  late MockTimeService timeService;
  late MockInterstitialAdService adService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  final today = DateTime(2026, 8, 11);

  GuidedSetupController controller() =>
      container.read(guidedSetupControllerProvider.notifier);

  Future<GuidedSetupState> state() =>
      container.read(guidedSetupControllerProvider.future);

  setUp(() {
    userSettings = MockUserSettingsRepository();
    migrationRepository = MockCurrencyMigrationRepository();
    servicesRepository = MockServicesRepository();
    serviceTypeRepository = MockServiceTypeRepository();
    authService = MockAuthService();
    analytics = MockAnalyticsService();
    timeService = MockTimeService();
    adService = MockInterstitialAdService();

    when(authService.user).thenReturn(userMock);
    when(timeService.now).thenReturn(today);
    when(
      analytics.log(any, parameters: anyNamed('parameters')),
    ).thenAnswer((_) async {});
    when(userSettings.setProfession(any, any)).thenAnswer((_) async {});
    when(userSettings.setDefaultCurrency(any, any)).thenAnswer((_) async {});
    when(
      userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
    ).thenAnswer((_) async {});
    when(
      migrationRepository.backfillCurrency(any, any),
    ).thenAnswer((_) async => 0);
    when(userSettings.setBillingCycle(any, any)).thenAnswer((_) async {});
    when(userSettings.markSetupCompleted(any)).thenAnswer((_) async {});
    when(userSettings.markSetupSkipped(any)).thenAnswer((_) async {});
    when(serviceTypeRepository.get(any)).thenAnswer((_) async => []);
    when(serviceTypeRepository.update(any)).thenAnswer((_) async {});
    when(serviceTypeRepository.addAll(any)).thenAnswer(
      (invocation) async => [
        for (final (index, type)
            in (invocation.positionalArguments.first as List<ServiceType>)
                .indexed)
          type.copyWith(id: 'type_$index'),
      ],
    );
    when(servicesRepository.add(any)).thenAnswer(
      (invocation) async => [invocation.positionalArguments.first as Service],
    );

    container = ProviderContainer(
      overrides: [
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        currencyMigrationRepositoryProvider.overrideWithValue(
          migrationRepository,
        ),
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        authServiceProvider.overrideWithValue(authService),
        analyticsServiceProvider.overrideWithValue(analytics),
        timeServiceProvider.overrideWithValue(timeService),
        interstitialAdServiceProvider.overrideWithValue(adService),
        kaziCurrencyControllerProvider.overrideWith(
          () => _FakeCurrencyController(SupportedCurrency.brl),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// A stalled account that built a catalog before giving up — one type, with
  /// the commission never configured.
  void withExistingCatalog() => when(serviceTypeRepository.get(any)).thenAnswer(
    (_) async => [
      ServiceType(id: 'existing_1', userId: userMock.uid, name: 'Mine'),
    ],
  );

  /// Walks the setup to the point where it can be completed.
  Future<void> fillIn({bool pickFirstService = true}) async {
    await state();
    final preset = PresetCatalog.byKey('manicure')!;
    await controller().chooseProfession(preset);

    if (pickFirstService) {
      final chosen = (await state()).selectedItems.first;
      controller().chooseFirstService(chosen.id);
      controller().chooseFirstServiceDate(today);
    }
  }

  group('seeding', () {
    test('Should write the selected catalog in one batch', () async {
      await fillIn();
      await controller().complete(registerService: false);

      final seeded =
          verify(serviceTypeRepository.addAll(captureAny)).captured.single
              as List<ServiceType>;

      // Exactly the pre-selected items of the kit, no more.
      final expected = PresetCatalog.byKey(
        'manicure',
      )!.services.where((service) => service.preSelected).length;
      expect(seeded, hasLength(expected));
      expect(seeded.every((type) => type.userId == userMock.uid), isTrue);
      expect(seeded.every((type) => type.currency == 'BRL'), isTrue);
      expect(seeded.every((type) => type.commissionPercent == 40), isTrue);
    });

    test('Should not seed over an existing catalog', () async {
      // The guard for the stalled segment: a user with a catalog of their own
      // must never have a preset written on top of it.
      withExistingCatalog();

      await fillIn(pickFirstService: false);
      await controller().complete(registerService: false);

      verifyNever(serviceTypeRepository.addAll(any));
      verify(userSettings.markSetupCompleted(any)).called(1);
    });

    test('Should offer the existing catalog instead of a preset', () async {
      // Showing a kit that the seed will refuse to write would make every tap
      // on that screen a no-op — and leave the first-service screen with no
      // real type to register against.
      withExistingCatalog();
      await fillIn(pickFirstService: false);

      final items = (await state()).items;
      expect(items.map((item) => item.name), ['Mine']);
      expect(items.single.existingTypeId, 'existing_1');
      expect(items.single.selected, isTrue);
    });

    test('Should offer the kit default for an unconfigured commission',
        () async {
      // A type with no commission is exactly what makes the home understate
      // someone's earnings, so the setup arrives with a real number in it.
      withExistingCatalog();
      await fillIn(pickFirstService: false);

      expect((await state()).items.single.commissionPercent, 40);
    });

    test('Should write back an edit to an existing type', () async {
      withExistingCatalog();
      await fillIn(pickFirstService: false);

      controller().editItem('existing_1', name: 'Renamed', value: 210);
      await controller().complete(registerService: false);

      final updated =
          verify(serviceTypeRepository.update(captureAny)).captured.single
              as ServiceType;
      expect(updated.id, 'existing_1');
      expect(updated.name, 'Renamed');
      expect(updated.defaultValue, 210);
      expect(updated.commissionPercent, 40);
    });

    test('Should register the first service against an existing type',
        () async {
      // The defect this path had: with nothing seeded, matching by preset name
      // found no type and the service was silently never written.
      withExistingCatalog();
      await fillIn(pickFirstService: false);
      controller().editItem('existing_1', name: 'Mine', value: 200);
      controller().chooseFirstService('existing_1');
      controller().chooseFirstServiceDate(today);

      await controller().complete(registerService: true);

      final service =
          verify(servicesRepository.add(captureAny)).captured.single as Service;
      expect(service.typeId, 'existing_1');
      expect(service.value, 200);
      expect((await state()).hasRegisteredService, isTrue);
    });

    test('Should survive a failed write-back and still register', () async {
      // One line failing to save is not worth losing the setup over.
      withExistingCatalog();
      when(serviceTypeRepository.update(any)).thenThrow(ExternalError('boom'));

      await fillIn(pickFirstService: false);
      controller().editItem('existing_1', name: 'Mine', value: 200);
      controller().chooseFirstService('existing_1');
      controller().chooseFirstServiceDate(today);

      await controller().complete(registerService: true);

      verify(servicesRepository.add(any)).called(1);
      verify(userSettings.markSetupCompleted(any)).called(1);
    });

    test('Should not touch the ad coordinator', () async {
      // Nine counted creations at the default frequency of three would fire an
      // interstitial in the middle of the onboarding.
      await fillIn();
      await controller().complete(registerService: true);

      verifyNever(adService.showIfAvailable());
    });
  });

  group('completion order', () {
    test('Should stamp the setup only after every other write', () async {
      await fillIn();
      await controller().complete(registerService: true);

      verifyInOrder([
        serviceTypeRepository.addAll(any),
        servicesRepository.add(any),
        userSettings.setDefaultCurrency(any, any),
        migrationRepository.backfillCurrency(any, any),
        userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
        userSettings.setBillingCycle(any, any),
        userSettings.markSetupCompleted(any),
      ]);
    });

    test('Should abort before stamping when the currency write fails',
        () async {
      // `confirm` reports failure through its state instead of throwing, and
      // an errored migration still counts as required. Stamping the setup
      // complete on top of that would open the route gate onto the blocking
      // migration screen, so the user would lose the number they just earned.
      when(
        migrationRepository.backfillCurrency(any, any),
      ).thenThrow(ExternalError('offline'));

      await fillIn();
      await controller().complete(registerService: true);

      verifyNever(userSettings.markSetupCompleted(any));
      final result = await state();
      expect(result.status, BaseStateStatus.error);
      // Never advances to the closing screen: there is no number to celebrate
      // when the currency behind it was not saved, and staying put is what
      // lets the user retry.
      expect(result.step, isNot(SetupStep.result));
      expect(result.hasRegisteredService, isFalse);
    });

    test('Should leave no currency migration pending behind it', () async {
      // The trap this whole ordering exists for. The setup seeds service
      // types, so a `currencyMigratedAt` left unset would drop the user
      // straight into the blocking migration screen the moment they finish.
      await fillIn();
      await controller().complete(registerService: true);

      verify(
        userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
      ).called(1);

      when(userSettings.get(any)).thenAnswer(
        (_) async => UserSettings(currencyMigratedAt: today),
      );
      await container
          .read(currencyMigrationControllerProvider.notifier)
          .check();

      expect(
        container.read(currencyMigrationControllerProvider).isRequired,
        isFalse,
      );
    });

    test('Should leave the setup pending when the seed fails', () async {
      // An interrupted run has to come back, and it can only do that while
      // the stamp is unset.
      when(serviceTypeRepository.addAll(any)).thenThrow(
        ExternalError('boom'),
      );

      await fillIn();
      await controller().complete(registerService: true);

      verifyNever(userSettings.markSetupCompleted(any));
      expect((await state()).status, BaseStateStatus.error);
    });
  });

  group('first service', () {
    test('Should register the chosen service against its seeded type',
        () async {
      await fillIn();
      await controller().complete(registerService: true);

      final service =
          verify(servicesRepository.add(captureAny)).captured.single as Service;

      expect(service.userId, userMock.uid);
      expect(service.typeId, isNotEmpty);
      expect(service.currency, 'BRL');
      expect(service.date, today);
      expect(service.value, greaterThan(0));
    });

    test('Should register nothing when the user has not worked yet', () async {
      // The honest exit. The catalog is still built, so the home is not the
      // empty one this flow set out to remove.
      await fillIn(pickFirstService: false);
      await controller().complete(registerService: false);

      verifyNever(servicesRepository.add(any));
      verify(serviceTypeRepository.addAll(any)).called(1);
      expect((await state()).hasRegisteredService, isFalse);
    });

    test('Should report the take-home on the closing screen', () async {
      await fillIn();
      await controller().complete(registerService: true);

      final result = await state();
      expect(result.step, SetupStep.result);
      expect(result.registeredValue, isNotNull);
      // The kit keeps 40%, and the closing screen names that number.
      expect(result.registeredCommission, result.registeredValue! * 0.4);
    });
  });

  group('catalog editing', () {
    test('Should let a price be cleared without blocking', () async {
      await fillIn(pickFirstService: false);
      final item = (await state()).items.first;

      controller().editItem(item.id, name: item.name);

      final edited = (await state()).items.first;
      expect(edited.value, isNull);
      expect((await state()).canContinueFromCatalog, isTrue);
    });

    test('Should apply one commission to all but the overridden', () async {
      await fillIn(pickFirstService: false);
      final items = (await state()).items;

      controller().setCommissionFor(items.first.id, 55);
      controller().setCommissionForAll(30);

      final updated = (await state()).items;
      expect(updated.first.commissionPercent, 55);
      expect(updated.skip(1).every((item) => item.commissionPercent == 30),
          isTrue);
    });

    test('Should drop seeded prices when leaving BRL', () async {
      // Prices are Brazilian reference amounts; relabelling them with another
      // symbol would be inventing numbers.
      await fillIn(pickFirstService: false);
      controller().setCurrency(SupportedCurrency.usd);

      final items = (await state()).items;
      expect(items.every((item) => item.value == null), isTrue);
    });
  });

  group('exit', () {
    test('Should record the skip and the step it happened on', () async {
      await fillIn(pickFirstService: false);
      await controller().exit();

      verify(userSettings.markSetupSkipped(any)).called(1);
      verify(
        analytics.log(
          AnalyticsEvent.setupExited,
          parameters: anyNamed('parameters'),
        ),
      ).called(1);
    });

    test('Should hand a skipped stalled user back to the currency migration',
        () async {
      // Leaving the setup skips the currency question with it, so the older
      // blocking migration has to still be there to catch someone whose
      // existing service predates currencies. The route gate runs the
      // onboarding check first and this one second, so skipping one lands on
      // the other rather than on an unlabelled total.
      when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());
      when(servicesRepository.count(any)).thenAnswer((_) async => 1);

      await fillIn(pickFirstService: false);
      await controller().exit();

      final migration = container.read(
        currencyMigrationControllerProvider.notifier,
      );
      await migration.check();

      expect(
        container.read(currencyMigrationControllerProvider).isRequired,
        isTrue,
      );
      verifyNever(
        userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
      );
    });
  });
}

class _FakeCurrencyController extends KaziCurrencyController {
  _FakeCurrencyController(this._currency);

  final SupportedCurrency _currency;

  @override
  Future<SupportedCurrency> build() async => _currency;
}
