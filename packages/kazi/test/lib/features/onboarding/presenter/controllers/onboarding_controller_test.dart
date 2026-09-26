import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_segment.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fakes/fake_time_service.dart';
import '../../../../../utils/test_helper.dart';
import 'onboarding_controller_test.mocks.dart';

@GenerateMocks([UserSettingsRepository, ServicesRepository, AuthService])
void main() {
  late MockUserSettingsRepository userSettings;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  Future<OnboardingSegment> segment() =>
      container.read(onboardingControllerProvider.future);

  void build() {
    container = ProviderContainer(
      overrides: [
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        authServiceProvider.overrideWithValue(authService),
        kaziAuthServiceProvider.overrideWithValue(_SignedIn()),
        timeServiceProvider.overrideWithValue(FakeTimeService()),
      ],
    );
    addTearDown(container.dispose);
    // Unlistened, riverpod pauses the provider and the auth stream never emits.
    container.listen(onboardingControllerProvider, (_, _) {});
  }

  setUp(() {
    userSettings = MockUserSettingsRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());
    when(servicesRepository.count(any)).thenAnswer((_) async => 0);
    when(
      servicesRepository.countDatedSince(any, any),
    ).thenAnswer((_) async => 1);
    when(
      userSettings.markSetupCompleted(
        any,
        essentialsOnly: anyNamed('essentialsOnly'),
      ),
    ).thenAnswer((_) async {});
  });

  group('segmentation', () {
    test('Should treat an account with nothing registered as fresh', () async {
      build();
      expect(await segment(), OnboardingSegment.fresh);
    });

    test('Should send a recently used account to the essentials', () async {
      // Older than the setup and in use: it has a catalog of its own, so no kit.
      for (final count in [1, 2, 40]) {
        when(servicesRepository.count(any)).thenAnswer((_) async => count);
        build();
        expect(await segment(), OnboardingSegment.returning);
      }
    });

    test(
      'Should give the full setup when nothing was registered in a month',
      () async {
        when(servicesRepository.count(any)).thenAnswer((_) async => 7);
        when(
          servicesRepository.countDatedSince(any, any),
        ).thenAnswer((_) async => 0);
        build();

        expect(await segment(), OnboardingSegment.dormant);
        expect(OnboardingSegment.dormant.requiresSetup, isTrue);
        // One calendar month before the fake clock's 2026-07-15.
        verify(
          servicesRepository.countDatedSince(any, DateTime(2026, 6, 15)),
        ).called(1);
      },
    );

    test('Should not ask again once the setup was completed', () async {
      when(
        userSettings.get(any),
      ).thenAnswer((_) async => UserSettings(setupCompletedAt: DateTime(2026)));
      build();
      expect(await segment(), OnboardingSegment.done);
    });

    test('Should treat a completed account with services as active', () async {
      when(
        userSettings.get(any),
      ).thenAnswer((_) async => UserSettings(setupCompletedAt: DateTime(2026)));
      when(servicesRepository.count(any)).thenAnswer((_) async => 2);
      build();

      final result = await segment();
      expect(result, OnboardingSegment.active);
      expect(result.requiresSetup, isFalse);
    });
  });

  group('safety', () {
    test('Should fail open when the lookup throws', () async {
      // A network blip may cost someone the onboarding; it may never cost
      // them the app.
      when(userSettings.get(any)).thenThrow(Exception('offline'));
      build();
      expect(await segment(), OnboardingSegment.done);
    });

    test('Should resolve to done with no signed-in user', () async {
      when(authService.user).thenReturn(null);
      build();
      expect(await segment(), OnboardingSegment.done);
    });
  });

  group('stamps', () {
    test('Should release the gate on completion', () async {
      build();
      await segment();

      await container
          .read(onboardingControllerProvider.notifier)
          .markCompleted(essentialsOnly: false);

      verify(
        userSettings.markSetupCompleted(any, essentialsOnly: false),
      ).called(1);
      expect(
        container.read(onboardingControllerProvider).value,
        OnboardingSegment.done,
      );
    });
  });

  group('debug replay', () {
    test('Should recompute the segment from the cleared stamps', () async {
      var completed = true;
      when(userSettings.get(any)).thenAnswer(
        (_) async =>
            UserSettings(setupCompletedAt: completed ? DateTime(2026) : null),
      );
      when(userSettings.resetOnboardingForDebug(any)).thenAnswer((_) async {
        completed = false;
      });
      when(servicesRepository.count(any)).thenAnswer((_) async => 5);
      build();
      expect(await segment(), OnboardingSegment.active);

      await container
          .read(onboardingControllerProvider.notifier)
          .replayForDebug();

      verify(userSettings.resetOnboardingForDebug(any)).called(1);
      expect(await segment(), OnboardingSegment.returning);
    });
  });
}

class _SignedIn implements KaziAuthService {
  @override
  Stream<bool> authStateChanges() => Stream.value(true);
}
