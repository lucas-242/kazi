import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/onboarding/domain/models/checklist_step.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'checklist_controller_test.mocks.dart';

@GenerateMocks([
  UserSettingsRepository,
  ServicesRepository,
  ServiceTypeRepository,
  AuthService,
  AnalyticsService,
])
void main() {
  late MockUserSettingsRepository userSettings;
  late MockServicesRepository servicesRepository;
  late MockServiceTypeRepository serviceTypeRepository;
  late MockAuthService authService;
  late MockAnalyticsService analytics;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  /// A user who has been through the setup — the only audience the trail has.
  final resolvedSetup = UserSettings(setupCompletedAt: DateTime(2026));

  Future<ChecklistState> state() =>
      container.read(checklistControllerProvider.future);

  void build() {
    container = ProviderContainer(
      overrides: [
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        authServiceProvider.overrideWithValue(authService),
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);
  }

  void withCatalog(int types) => when(
    serviceTypeRepository.get(any),
  ).thenAnswer(
    (_) async => [
      for (var i = 0; i < types; i++)
        ServiceType(userId: userMock.uid, name: 'Type $i'),
    ],
  );

  setUp(() {
    userSettings = MockUserSettingsRepository();
    servicesRepository = MockServicesRepository();
    serviceTypeRepository = MockServiceTypeRepository();
    authService = MockAuthService();
    analytics = MockAnalyticsService();

    when(authService.user).thenReturn(userMock);
    when(userSettings.get(any)).thenAnswer((_) async => resolvedSetup);
    when(userSettings.markOnboardingStep(any, any)).thenAnswer((_) async {});
    when(
      analytics.log(any, parameters: anyNamed('parameters')),
    ).thenAnswer((_) async {});
    when(servicesRepository.count(any)).thenAnswer((_) async => 0);
    withCatalog(0);
  });

  group('derivation', () {
    test('Should tick the catalog step from the user data', () async {
      withCatalog(3);
      build();

      final result = await state();
      expect(result.isDone(ChecklistStep.catalog), isTrue);
      expect(result.isDone(ChecklistStep.firstService), isFalse);
    });

    test('Should tick the first service at one record', () async {
      withCatalog(3);
      when(servicesRepository.count(any)).thenAnswer((_) async => 1);
      build();

      final result = await state();
      expect(result.isDone(ChecklistStep.firstService), isTrue);
      expect(result.isDone(ChecklistStep.threeServices), isFalse);
      expect(result.doneCount, 2);
    });

    test('Should tick the habit step at three records', () async {
      withCatalog(3);
      when(servicesRepository.count(any)).thenAnswer((_) async => 3);
      build();

      expect((await state()).isDone(ChecklistStep.threeServices), isTrue);
    });

    test('Should read the recorded steps off the user document', () async {
      // These two have no cheap query behind them, so they are stamped when
      // they happen rather than derived.
      when(userSettings.get(any)).thenAnswer(
        (_) async => UserSettings(
          setupCompletedAt: DateTime(2026),
          completedOnboardingSteps: {
            ChecklistStep.markReceived.key,
            ChecklistStep.seeSummary.key,
          },
        ),
      );
      build();

      final result = await state();
      expect(result.isDone(ChecklistStep.markReceived), isTrue);
      expect(result.isDone(ChecklistStep.seeSummary), isTrue);
    });
  });

  group('visibility', () {
    test('Should show for someone the setup ran for', () async {
      withCatalog(3);
      build();
      expect((await state()).isVisible, isTrue);
    });

    test('Should stay hidden for a user the setup never ran for', () async {
      // Someone already using the app. A "build your catalog" list on their
      // home would tell them the app has no idea who they are.
      when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());
      build();

      final result = await state();
      expect(result.isVisible, isFalse);
      expect(result.doneCount, 0);
    });

    test('Should disappear once every step is done', () async {
      withCatalog(3);
      when(servicesRepository.count(any)).thenAnswer((_) async => 3);
      when(userSettings.get(any)).thenAnswer(
        (_) async => UserSettings(
          setupCompletedAt: DateTime(2026),
          completedOnboardingSteps: {
            ChecklistStep.markReceived.key,
            ChecklistStep.seeSummary.key,
          },
        ),
      );
      build();

      final result = await state();
      expect(result.doneCount, ChecklistStep.values.length);
      expect(result.isVisible, isFalse);
    });

    test('Should disappear for someone who clearly got the hang of it',
        () async {
      // Ten services in, an unfinished to-do list is just clutter.
      withCatalog(3);
      when(servicesRepository.count(any)).thenAnswer((_) async => 10);
      build();

      expect((await state()).isVisible, isFalse);
    });

    test('Should stay hidden when the lookup throws', () async {
      when(userSettings.get(any)).thenThrow(Exception('offline'));
      build();
      expect((await state()).isVisible, isFalse);
    });
  });

  group('recording', () {
    test('Should stamp a recorded step once', () async {
      withCatalog(3);
      build();
      await state();

      final controller = container.read(checklistControllerProvider.notifier);
      await controller.markStep(ChecklistStep.markReceived);

      verify(
        userSettings.markOnboardingStep(any, ChecklistStep.markReceived.key),
      ).called(1);
    });

    test('Should not rewrite a step already recorded', () async {
      // Marking a tenth service as received must cost nothing.
      withCatalog(3);
      when(userSettings.get(any)).thenAnswer(
        (_) async => UserSettings(
          setupCompletedAt: DateTime(2026),
          completedOnboardingSteps: {ChecklistStep.markReceived.key},
        ),
      );
      build();
      await state();

      await container
          .read(checklistControllerProvider.notifier)
          .markStep(ChecklistStep.markReceived);

      verifyNever(userSettings.markOnboardingStep(any, any));
    });
  });
}
