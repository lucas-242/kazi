// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'service_landing_controller_test.mocks.dart';

@GenerateMocks([ServiceTypeRepository, ServicesRepository, AuthService])
void main() {
  late MockServiceTypeRepository serviceTypeRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late LocalTimeService timeService;
  late ServicesService servicesService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  ServiceLandingController controller() =>
      container.read(serviceLandingControllerProvider.notifier);
  ServiceLandingState state() =>
      container.read(serviceLandingControllerProvider);

  // Flushes microtasks so fire-and-forget async work in the controller settles.
  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 10));

  List<Override> overridesWith(ServicesService service) => [
    servicesRepositoryProvider.overrideWithValue(servicesRepository),
    serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
    authServiceProvider.overrideWithValue(authService),
    servicesServiceProvider.overrideWithValue(service),
  ];

  // Rebuilds the container with a different ServicesService (used to control
  // the clock for FastSearch date-range assertions).
  void useServicesService(ServicesService service) {
    container.dispose();
    container = ProviderContainer(overrides: overridesWith(service));
  }

  setUp(() async {
    serviceTypeRepository = MockServiceTypeRepository();
    servicesRepository = MockServicesRepository();
    timeService = LocalTimeService(serviceMock.date);
    servicesService = LocalServicesService(timeService);
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesWithIdsMock);
    when(
      servicesRepository.get(any, any, any),
    ).thenAnswer((_) async => servicesWithTypeIdMock);
    when(servicesRepository.delete(any)).thenAnswer((_) => Future.value());

    container = ProviderContainer(overrides: overridesWith(servicesService));
  });

  tearDown(() {
    container.dispose();
  });

  group('onInit', () {
    test('loads services ordered alphabetical and status success', () async {
      await controller().onInit();
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(
        state().services,
        servicesService.orderServices(
          servicesWithTypesMock,
          OrderBy.alphabetical,
          currency: SupportedCurrency.usd,
          rateBook: const RateBook.empty(),
        ),
      );
    });

    test('status noData when there are no services', () async {
      when(
        servicesRepository.get(any, any, any),
      ).thenAnswer((_) async => []);

      await controller().onInit();
      await pump();

      expect(state().status, BaseStateStatus.noData);
    });

    test('status error with errorToGetServices when get throws AppError',
        () async {
      when(servicesRepository.get(any, any, any)).thenThrow(
        ExternalError(KaziLocalizations.current.errorToGetServices),
      );

      await controller().onInit();
      await pump();

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
      await pump();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorToGetServiceTypes,
      );
    });

    test('status error with unknowError on unexpected exception', () async {
      when(serviceTypeRepository.get(any)).thenThrow(Exception());

      await controller().onInit();
      await pump();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('deleteService', () {
    test('deletes and refetches, ending in success', () async {
      final serviceToDelete = serviceMock.copyWith(id: '123456', typeId: '1');

      await controller().deleteService(serviceToDelete);
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(
        state().services,
        servicesService.orderServices(
          servicesWithTypesMock,
          OrderBy.alphabetical,
          currency: SupportedCurrency.usd,
          rateBook: const RateBook.empty(),
        ),
      );
      verify(servicesRepository.delete(serviceToDelete.id)).called(1);
    });
  });

  group('onRefresh', () {
    test('ends in success after refetching', () async {
      await controller().onRefresh();
      await pump();

      expect(state().status, BaseStateStatus.success);
    });
  });

  group('onApplyFilters', () {
    test('with custom dates updates range and marks didFiltersChange',
        () async {
      final newStartDateTime = DateTime(2022, 1, 1);
      final newEndDateTime = DateTime(2022, 1, 12);

      await controller().onApplyFilters(null, newStartDateTime, newEndDateTime);
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(state().startDate, newStartDateTime);
      expect(state().endDate, newEndDateTime);
      expect(state().fastSearch, FastSearch.custom);
      expect(state().didFiltersChange, isTrue);
    });

    test('with a FastSearch updates fastSearch and marks didFiltersChange',
        () async {
      useServicesService(
        LocalServicesService(LocalTimeService(DateTime(2022, 12, 12))),
      );

      await controller().onApplyFilters(FastSearch.fortnight);
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(state().fastSearch, FastSearch.fortnight);
      expect(state().didFiltersChange, isTrue);
      expect(state().startDate, DateTime(2022, 12, 1));
      expect(state().endDate, DateTime(2022, 12, 15, 23, 59, 59));
    });
  });

  group('onChangeServices', () {
    test('ends in success with the refetched services', () async {
      await controller().onChangeServices();
      await pump();

      expect(state().status, BaseStateStatus.success);
      expect(state().services, servicesWithTypesMock);
    });
  });

  group('onChangeOrderBy', () {
    test('reorders services and updates selectedOrderBy', () async {
      await controller().onInit();
      await pump();

      controller().onChangeOrderBy(OrderBy.dateDesc);

      expect(state().selectedOrderBy, OrderBy.dateDesc);
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
  });

  group('State properties', () {
    ServiceLandingState buildState() => ServiceLandingState(
      services: servicesWithTypesMock,
      status: BaseStateStatus.success,
      selectedOrderBy: OrderBy.dateDesc,
      startDate: servicesService.now,
      endDate: servicesService.now,
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
