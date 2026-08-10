import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'billing_cycle_controller_test.mocks.dart';

@GenerateMocks([UserSettingsRepository, AuthService])
void main() {
  late MockUserSettingsRepository userSettings;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  BillingCycleController controller() =>
      container.read(billingCycleControllerProvider.notifier);

  setUp(() {
    userSettings = MockUserSettingsRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());
    when(userSettings.setBillingCycle(any, any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
    addTearDown(container.dispose);
  });

  group('build', () {
    test('Should read the cycle from the user document', () async {
      when(userSettings.get(any)).thenAnswer(
        (_) async =>
            const UserSettings(billingCycle: FortnightlyCycle(anchorDay: 5)),
      );

      final cycle = await container.read(billingCycleControllerProvider.future);

      expect(cycle, const FortnightlyCycle(anchorDay: 5));
    });

    test('Should default for a user who never set one', () async {
      final cycle = await container.read(billingCycleControllerProvider.future);

      expect(cycle, BillingCycle.monthlyDefault);
    });

    /// Fail-open: the home still renders over the calendar month rather than
    /// showing an error state because a settings read timed out.
    test('Should default when the read throws', () async {
      when(userSettings.get(any)).thenThrow(Exception());

      final cycle = await container.read(billingCycleControllerProvider.future);

      expect(cycle, BillingCycle.monthlyDefault);
    });

    test('Should default when there is no signed-in user', () async {
      when(authService.user).thenReturn(null);

      final cycle = await container.read(billingCycleControllerProvider.future);

      expect(cycle, BillingCycle.monthlyDefault);
      verifyNever(userSettings.get(any));
    });
  });

  group('select', () {
    test('Should persist the cycle and publish it', () async {
      await container.read(billingCycleControllerProvider.future);

      await controller().select(const MonthlyCycle(anchorDay: 5));

      verify(
        userSettings.setBillingCycle(
          userMock.uid,
          const MonthlyCycle(anchorDay: 5),
        ),
      ).called(1);
      expect(
        container.read(billingCycleControllerProvider).asData?.value,
        const MonthlyCycle(anchorDay: 5),
      );
    });

    /// The opposite of [build]: the user asked for this, so a write that did
    /// not land must surface instead of leaving the UI claiming a cycle the
    /// account does not have.
    test(
      'Should rethrow and keep the old cycle when the write fails',
      () async {
        await container.read(billingCycleControllerProvider.future);
        when(userSettings.setBillingCycle(any, any)).thenThrow(Exception());

        expect(
          () => controller().select(const MonthlyCycle(anchorDay: 5)),
          throwsException,
        );
        expect(
          container.read(billingCycleControllerProvider).asData?.value,
          BillingCycle.monthlyDefault,
        );
      },
    );
  });

  group('billingCycleProvider', () {
    test('Should fall back to the default while loading', () {
      expect(container.read(billingCycleProvider), BillingCycle.monthlyDefault);
    });

    test('Should expose the resolved cycle', () async {
      when(userSettings.get(any)).thenAnswer(
        (_) async =>
            const UserSettings(billingCycle: WeeklyCycle(anchorWeekday: 5)),
      );

      await container.read(billingCycleControllerProvider.future);

      expect(
        container.read(billingCycleProvider),
        const WeeklyCycle(anchorWeekday: 5),
      );
    });
  });
}
