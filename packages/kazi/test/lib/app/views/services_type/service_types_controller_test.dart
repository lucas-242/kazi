import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/services/service_types/service_types_controller.dart';
import 'package:kazi/features/services/service_types/service_types_state.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/injector_container.dart';
import 'package:kazi_core/kazi_core.dart'
    hide ServiceType, ServiceTypeRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/mocks.dart';
import '../../../../utils/test_helper.dart';
import 'service_types_controller_test.mocks.dart';

@GenerateMocks([ServiceTypeRepository, ServicesRepository, AuthService])
void main() {
  late MockServiceTypeRepository serviceTypeRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  ServiceTypesController controller() =>
      container.read(serviceTypesControllerProvider.notifier);
  ServiceTypesState state() => container.read(serviceTypesControllerProvider);

  setUp(() async {
    serviceTypeRepository = MockServiceTypeRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesMock);
    when(
      serviceTypeRepository.add(any),
    ).thenAnswer((_) async => serviceTypeMock);

    await serviceLocator.reset();
    serviceLocator.registerSingleton<ServicesRepository>(servicesRepository);
    serviceLocator.registerSingleton<ServiceTypeRepository>(
      serviceTypeRepository,
    );
    serviceLocator.registerSingleton<AuthService>(authService);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('onInit', () {
    test('loads serviceTypes and status readyToUserInput', () async {
      await controller().onInit();

      expect(state().status, BaseStateStatus.readyToUserInput);
      expect(state().serviceTypes, serviceTypesMock);
    });

    test('status noData when there are no serviceTypes', () async {
      when(serviceTypeRepository.get(any)).thenAnswer((_) async => []);

      await controller().onInit();

      expect(state().status, BaseStateStatus.noData);
      expect(state().serviceTypes, isEmpty);
    });
  });

  group('getServiceTypes', () {
    test('loads serviceTypes and ends readyToUserInput', () async {
      await controller().getServiceTypes();

      expect(state().status, BaseStateStatus.readyToUserInput);
      expect(state().serviceTypes, serviceTypesMock);
    });

    test('status error with errorToGetServiceTypes on AppError', () async {
      when(serviceTypeRepository.get(any)).thenThrow(
        ExternalError(KaziLocalizations.current.errorToGetServiceTypes),
      );

      await controller().getServiceTypes();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorToGetServiceTypes,
      );
    });

    test('status error with unknowError on unexpected exception', () async {
      when(serviceTypeRepository.get(any)).thenThrow(Exception());

      await controller().getServiceTypes();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('addServiceType', () {
    test('adds the serviceType and ends in success with reset serviceType',
        () async {
      controller().changeServiceType(serviceTypeMock);
      await controller().addServiceType();

      expect(state().status, BaseStateStatus.success);
      expect(state().serviceTypes, [serviceTypeMock]);
      expect(state().serviceType.id, isEmpty);
    });
  });

  group('updateServiceType', () {
    test('updates and refetches serviceTypes, ending in success', () async {
      controller().changeServiceType(serviceTypeMock);
      await controller().updateServiceType();

      expect(state().status, BaseStateStatus.success);
      expect(state().serviceTypes, serviceTypesMock);
    });
  });

  group('deleteServiceType', () {
    setUp(() {
      when(servicesRepository.count(any, any)).thenAnswer((_) async => 0);
    });

    test('deletes and refetches serviceTypes, ending in success', () async {
      final serviceTypeToDelete = serviceTypeMock.copyWith(id: '123456');

      await controller().deleteServiceType(serviceTypeToDelete);

      expect(state().status, BaseStateStatus.success);
      expect(state().serviceTypes, serviceTypesMock);
    });
  });

  group('change properties', () {
    const newName = 'new name';
    const newDefaultValue = 9999.0;
    const newDiscountPercent = 1.0;

    test('eraseServiceType resets serviceType', () {
      controller().changeServiceType(serviceTypeMock);
      controller().eraseServiceType();

      expect(state().serviceType.id, isEmpty);
      expect(state().serviceType.name, isEmpty);
    });

    test('changeServiceTypeName updates name', () {
      controller().changeServiceType(serviceTypeMock);
      controller().changeServiceTypeName(newName);

      expect(state().serviceType, serviceTypeMock.copyWith(name: newName));
    });

    test('changeServiceTypeDefaultValue updates defaultValue', () {
      controller().changeServiceType(serviceTypeMock);
      controller().changeServiceTypeDefaultValue(newDefaultValue);

      expect(
        state().serviceType,
        serviceTypeMock.copyWith(defaultValue: newDefaultValue),
      );
    });

    test('changeServiceTypeDiscountPercent updates discountPercent', () {
      controller().changeServiceType(serviceTypeMock);
      controller().changeServiceTypeDiscountPercent(newDiscountPercent);

      expect(
        state().serviceType,
        serviceTypeMock.copyWith(discountPercent: newDiscountPercent),
      );
    });
  });
}
