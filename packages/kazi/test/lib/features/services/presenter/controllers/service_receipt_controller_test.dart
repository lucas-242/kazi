import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/presenter/controllers/live_service_provider.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_receipt_controller.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'service_receipt_controller_test.mocks.dart';

@GenerateMocks([
  ServicesRepository,
  ServiceTypeRepository,
  AuthService,
  UserSettingsRepository,
])
void main() {
  final now = DateTime(2026, 9, 5);

  late MockServicesRepository servicesRepository;
  late MockServiceTypeRepository serviceTypeRepository;
  late MockAuthService authService;
  late MockUserSettingsRepository userSettings;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  Service service(String id, {DateTime? receivedAt}) => Service(
    id: id,
    value: 100,
    discountPercent: 60,
    typeId: '1',
    date: DateTime(2026, 8, 20),
    receivedAt: receivedAt,
    userId: userMock.uid,
  );

  ServiceReceiptController controller() =>
      container.read(serviceReceiptControllerProvider.notifier);

  setUp(() {
    servicesRepository = MockServicesRepository();
    serviceTypeRepository = MockServiceTypeRepository();
    authService = MockAuthService();
    userSettings = MockUserSettingsRepository();

    final clock = LocalTimeService(now);

    when(authService.user).thenReturn(userMock);
    when(servicesRepository.setReceivedAt(any, any)).thenAnswer((_) async {});
    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesWithIdsMock);
    when(userSettings.get(any)).thenAnswer((_) async => const UserSettings());

    container = ProviderContainer(
      overrides: [
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        authServiceProvider.overrideWithValue(authService),
        userSettingsRepositoryProvider.overrideWithValue(userSettings),
        timeServiceProvider.overrideWithValue(clock),
        servicesServiceProvider.overrideWithValue(LocalServicesService(clock)),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Seeds both lists with the same services, the way they look after a fetch.
  void seedLists(List<Service> services) {
    container.read(dashboardControllerProvider.notifier).applyReceipt(const {});
    container.read(serviceLandingControllerProvider.notifier).state = container
        .read(serviceLandingControllerProvider)
        .copyWith(services: services);
    container.read(dashboardControllerProvider.notifier).state = container
        .read(dashboardControllerProvider)
        .copyWith(services: services);
  }

  group('setReceived', () {
    test('Should stamp with the app clock, not the server', () async {
      await controller().setReceived([service('a')], received: true);

      verify(servicesRepository.setReceivedAt(['a'], now)).called(1);
    });

    test('Should clear the stamp when received is false', () async {
      await controller().setReceived([
        service('a', receivedAt: now),
      ], received: false);

      verify(servicesRepository.setReceivedAt(['a'], null)).called(1);
    });

    test('Should not write for an empty selection', () async {
      final ids = await controller().setReceived(const [], received: true);

      expect(ids, isEmpty);
      verifyNever(servicesRepository.setReceivedAt(any, any));
    });

    /// Both lists are patched in memory rather than refetched: the repository
    /// reads cache-first, so a refetch could hand back the pre-write state.
    test('Should patch both lists without refetching', () async {
      seedLists([service('a'), service('b')]);

      await controller().setReceived([service('a')], received: true);

      final landing = container.read(serviceLandingControllerProvider).services;
      final dashboard = container.read(dashboardControllerProvider).services;

      expect(landing.firstWhere((s) => s.id == 'a').receivedAt, now);
      expect(landing.firstWhere((s) => s.id == 'b').isReceived, isFalse);
      expect(dashboard.firstWhere((s) => s.id == 'a').receivedAt, now);
      verifyNever(servicesRepository.get(any, any, any));
    });

    test('Should clear the stamp in memory too', () async {
      seedLists([service('a', receivedAt: now)]);

      await controller().setReceived([
        service('a', receivedAt: now),
      ], received: false);

      expect(
        container
            .read(serviceLandingControllerProvider)
            .services
            .first
            .isReceived,
        isFalse,
      );
    });

    test('Should ignore ids that no list holds', () async {
      seedLists([service('a')]);

      await controller().setReceivedByIds(['zzz'], received: true);

      expect(
        container.read(serviceLandingControllerProvider).services.first.id,
        'a',
      );
    });
  });

  group('markListedAsReceived', () {
    test('Should stamp only what is listed and still owed', () async {
      seedLists([
        service('a'),
        service('b', receivedAt: DateTime(2026, 8, 30)),
        service('c'),
      ]);

      final ids = await container
          .read(serviceLandingControllerProvider.notifier)
          .markListedAsReceived();

      // 'b' is left alone: restamping it would move a payment date the user
      // already recorded.
      expect(ids, ['a', 'c']);
      verify(servicesRepository.setReceivedAt(['a', 'c'], now)).called(1);
    });

    /// The consequence of acting on the visible list rather than on the cycle:
    /// narrowing the filter narrows what gets stamped.
    test('Should never reach beyond the listed services', () async {
      seedLists([service('a')]);

      await container
          .read(serviceLandingControllerProvider.notifier)
          .markListedAsReceived();

      verify(servicesRepository.setReceivedAt(['a'], now)).called(1);
      verifyNoMoreInteractions(servicesRepository);
    });

    test('Should do nothing when everything is already paid', () async {
      seedLists([service('a', receivedAt: now)]);

      final ids = await container
          .read(serviceLandingControllerProvider.notifier)
          .markListedAsReceived();

      expect(ids, isEmpty);
      verifyNever(servicesRepository.setReceivedAt(any, any));
    });
  });

  group('liveService', () {
    test('Should follow the stamp so the details page can repaint', () async {
      seedLists([service('a')]);
      expect(container.read(liveServiceProvider('a'))!.isReceived, isFalse);

      await controller().setReceived([service('a')], received: true);

      expect(container.read(liveServiceProvider('a'))!.receivedAt, now);
    });

    test('Should return null for a service no list holds', () {
      seedLists([service('a')]);

      expect(container.read(liveServiceProvider('zzz')), isNull);
    });
  });
}
