import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_controller.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fakes/fake_analytics_service.dart';
import '../../../../../utils/test_helper.dart';
import 'currency_migration_controller_test.mocks.dart';

@GenerateMocks([
  UserSettingsRepository,
  CurrencyMigrationRepository,
  AuthService,
])
void main() {
  late MockUserSettingsRepository userSettings;
  late MockCurrencyMigrationRepository migration;
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
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(userSettings.setDefaultCurrency(any, any)).thenAnswer((_) async {});
    when(
      userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
    ).thenAnswer((_) async {});
    when(migration.backfillCurrency(any, any)).thenAnswer((_) async => 12);

    container = ProviderContainer(
      overrides: [
        // The controller reports what it did. Without this the real composite
        // is built, and its Firebase sink needs an initialised Firebase app a
        // unit test does not have.
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        currencyMigrationRepositoryProvider.overrideWithValue(migration),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('confirm', () {
    test('backfills and only then records the flag', () async {
      await controller().confirm(SupportedCurrency.brl);

      verifyInOrder([
        userSettings.setDefaultCurrency(userMock.uid, SupportedCurrency.brl),
        migration.backfillCurrency(userMock.uid, SupportedCurrency.brl),
        userSettings.markCurrencyMigrated(userMock.uid, migrated: 12),
      ]);
      expect(state().status, CurrencyMigrationStatus.done);
    });

    test('leaves the flag unset when the backfill fails', () async {
      // The setup that ran it stays pending, so it comes back next launch and
      // the already-updated documents are skipped.
      when(
        migration.backfillCurrency(any, any),
      ).thenThrow(ExternalError('network down'));

      await controller().confirm(SupportedCurrency.brl);

      expect(state().status, CurrencyMigrationStatus.error);
      verifyNever(
        userSettings.markCurrencyMigrated(any, migrated: anyNamed('migrated')),
      );
    });

    test('does nothing without a signed-in user', () async {
      when(authService.user).thenReturn(null);

      await controller().confirm(SupportedCurrency.brl);

      verifyNever(userSettings.setDefaultCurrency(any, any));
      expect(state().status, CurrencyMigrationStatus.idle);
    });
  });
}
