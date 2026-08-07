import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_controller.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'currency_migration_controller_test.mocks.dart';

@GenerateMocks([
  UserSettingsRepository,
  CurrencyMigrationRepository,
  ServicesRepository,
  ServiceTypeRepository,
  AuthService,
])
void main() {
  late MockUserSettingsRepository userSettings;
  late MockCurrencyMigrationRepository migration;
  late MockServicesRepository servicesRepository;
  late MockServiceTypeRepository serviceTypeRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  CurrencyMigrationController controller() =>
      container.read(currencyMigrationControllerProvider.notifier);
  CurrencyMigrationState state() =>
      container.read(currencyMigrationControllerProvider);

  setUp(() {
    userSettings = MockUserSettingsRepository();
    migration = MockCurrencyMigrationRepository();
    servicesRepository = MockServicesRepository();
    serviceTypeRepository = MockServiceTypeRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());
    when(userSettings.setDefaultCurrency(any, any)).thenAnswer((_) async {});
    when(
      userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
    ).thenAnswer((_) async {});
    when(servicesRepository.count(any)).thenAnswer((_) async => 12);
    when(serviceTypeRepository.get(any)).thenAnswer((_) async => []);
    when(migration.backfillCurrency(any, any)).thenAnswer((_) async => 12);

    container = ProviderContainer(
      overrides: [
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        currencyMigrationRepositoryProvider.overrideWithValue(migration),
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('check', () {
    test('requires the migration when the user has data and no flag', () async {
      await controller().check();

      expect(state().isRequired, isTrue);
      expect(state().affectedServices, 12);
    });

    test('does not ask a user who already migrated', () async {
      when(userSettings.get(any)).thenAnswer(
        (_) async => UserSettings(
          defaultCurrency: SupportedCurrency.brl,
          currencyMigratedAt: DateTime(2026),
        ),
      );

      await controller().check();

      expect(state().isRequired, isFalse);
    });

    test('completes silently for a user with nothing to reinterpret', () async {
      when(servicesRepository.count(any)).thenAnswer((_) async => 0);

      await controller().check();

      expect(state().isRequired, isFalse);
      verify(
        userSettings.markCurrencyMigrated(any, migrated: 0),
      ).called(1);
      verifyNever(migration.backfillCurrency(any, any));
    });

    test('still asks when the user only has service types', () async {
      when(servicesRepository.count(any)).thenAnswer((_) async => 0);
      when(
        serviceTypeRepository.get(any),
      ).thenAnswer((_) async => serviceTypesWithIdsMock);

      await controller().check();

      expect(state().isRequired, isTrue);
    });

    test('does not gate a signed-out user', () async {
      when(authService.user).thenReturn(null);

      await controller().check();

      expect(state().isRequired, isFalse);
    });

    test('fails open when the check itself throws', () async {
      // A network blip must not lock the user out of their own app.
      when(userSettings.get(any)).thenThrow(ExternalError('boom'));

      await controller().check();

      expect(state().isRequired, isFalse);
    });
  });

  group('confirm', () {
    test('backfills and only then records the flag', () async {
      await controller().check();
      await controller().confirm(SupportedCurrency.brl);

      verifyInOrder([
        userSettings.setDefaultCurrency(userMock.uid, SupportedCurrency.brl),
        migration.backfillCurrency(userMock.uid, SupportedCurrency.brl),
        userSettings.markCurrencyMigrated(userMock.uid, migrated: 12),
      ]);
      expect(state().isRequired, isFalse);
    });

    test('keeps the gate closed when the backfill fails', () async {
      // The flag stays unset, so the migration is retried next launch and the
      // already-updated documents are skipped.
      when(
        migration.backfillCurrency(any, any),
      ).thenThrow(ExternalError('network down'));

      await controller().check();
      await controller().confirm(SupportedCurrency.brl);

      expect(state().status, CurrencyMigrationStatus.error);
      expect(state().isRequired, isTrue);
      verifyNever(
        userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
      );
    });
  });
}
