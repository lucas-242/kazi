import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'dashboard_controller_test.mocks.dart';

@GenerateMocks([ServiceTypeRepository, ServicesRepository, AuthService])
void main() {
  late MockServiceTypeRepository serviceTypeRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late TimeService timeService;
  late ServicesService servicesService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  DashboardController controller() =>
      container.read(dashboardControllerProvider.notifier);
  DashboardState state() => container.read(dashboardControllerProvider);

  // Flushes microtasks so fire-and-forget async work in the controller settles.
  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 10));

  setUp(() async {
    serviceTypeRepository = MockServiceTypeRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();
    timeService = LocalTimeService();
    servicesService = LocalServicesService(timeService);

    when(authService.user).thenReturn(userMock);
    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesWithIdsMock);
    when(
      servicesRepository.get(any, any),
    ).thenAnswer((_) async => servicesWithTypeIdMock);

    container = ProviderContainer(
      overrides: [
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        authServiceProvider.overrideWithValue(authService),
        timeServiceProvider.overrideWithValue(timeService),
        servicesServiceProvider.overrideWithValue(servicesService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('onInit', () {
    test('loads services ordered by dateDesc and status success', () async {
      await controller().onInit();

      expect(state().status, BaseStateStatus.success);
      expect(
        state().services,
        servicesService.orderServices(
          servicesWithTypesMock,
          OrderBy.dateDesc,
          currency: SupportedCurrency.usd,
          rateBook: const RateBook.empty(),
        ),
      );
    });

    test('status noData when there are no services', () async {
      when(servicesRepository.get(any, any)).thenAnswer((_) async => []);

      await controller().onInit();

      expect(state().status, BaseStateStatus.noData);
      expect(state().services, isEmpty);
    });

    test('status error with errorToGetServices when get throws AppError',
        () async {
      when(servicesRepository.get(any, any)).thenThrow(
        ExternalError(KaziLocalizations.current.errorToGetServices),
      );

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorToGetServices,
      );
    });

    test('status error with errorToGetServiceTypes when types get throws',
        () async {
      when(serviceTypeRepository.get(any)).thenThrow(
        ExternalError(KaziLocalizations.current.errorToGetServiceTypes),
      );

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorToGetServiceTypes,
      );
    });

    test('status error with unknowError on unexpected exception', () async {
      when(serviceTypeRepository.get(any)).thenThrow(Exception());

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
      expect(state().callbackMessage, KaziLocalizations.current.errorUnknowError);
    });
  });

  group('onRefresh', () {
    test('ends in success with the refetched services', () async {
      await controller().onRefresh();
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(state().services, servicesWithTypesMock);
    });
  });

  group('State properties', () {
    DashboardState buildState() => DashboardState(
      services: servicesWithTypesMock,
      status: BaseStateStatus.success,
      selectedOrderBy: OrderBy.dateDesc,
    );

    test('totalValue should be 210', () {
      expect(buildState().totals.value, 210);
    });

    test('totalWithDiscount should be 105', () {
      expect(buildState().totals.withDiscount, 105);
    });

    test('totalDiscounted should be 105', () {
      expect(buildState().totals.discounted, 105);
    });
  });
}
