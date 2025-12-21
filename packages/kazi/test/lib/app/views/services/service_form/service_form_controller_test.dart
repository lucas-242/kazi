import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/app/repositories/service_type_repository/service_type_repository.dart';
import 'package:kazi/app/repositories/services_repository/services_repository.dart';
import 'package:kazi/app/services/auth_service/auth_service.dart';
import 'package:kazi/app/shared/utils/base_state.dart';
import 'package:kazi/app/views/services/service_form/service_form_controller.dart';
import 'package:kazi/app/views/services/service_form/service_form_state.dart';
import 'package:kazi/injector_container.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository, Service;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'service_form_cubit_test.mocks.dart';

@GenerateMocks([ServiceTypeRepository, ServicesRepository, AuthService])
void main() {
  late MockServiceTypeRepository serviceTypeRepository;
  late MockServicesRepository servicesRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  setUp(() async {
    serviceTypeRepository = MockServiceTypeRepository();
    servicesRepository = MockServicesRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);

    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesMock);

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

  group('Provider build', () {
    test('loads serviceTypes and returns readyToUserInput', () async {
      final provider = serviceFormControllerProvider();
      final state = await container.read(provider.future);

      expect(state.userId, authService.user!.uid);
      expect(state.serviceTypes, serviceTypesMock);
      expect(state.status, BaseStateStatus.readyToUserInput);
    });

    test('uses passed service when building', () async {
      final provider = serviceFormControllerProvider(service: serviceMock);
      final state = await container.read(provider.future);

      expect(state.service, serviceMock);
      expect(state.status, BaseStateStatus.readyToUserInput);
    });

    test('returns noData when serviceTypes is empty', () async {
      when(serviceTypeRepository.get(any)).thenAnswer((_) async => []);

      final provider = serviceFormControllerProvider();
      final state = await container.read(provider.future);

      expect(state.status, BaseStateStatus.noData);
    });

    test(
      'returns error state with callbackMessage when get serviceTypes throws AppError',
      () async {
        when(serviceTypeRepository.get(any)).thenThrow(
          ExternalError(KaziLocalizations.current.errorToGetServiceTypes),
        );

        final provider = serviceFormControllerProvider();
        final state = await container.read(provider.future);

        expect(state.status, BaseStateStatus.error);
        expect(
          state.callbackMessage,
          KaziLocalizations.current.errorToGetServiceTypes,
        );
      },
    );

    test(
      'returns unknowError when get serviceTypes throws unexpected exception',
      () async {
        when(serviceTypeRepository.get(any)).thenThrow(Exception());

        final provider = serviceFormControllerProvider();
        final state = await container.read(provider.future);

        expect(state.status, BaseStateStatus.error);
        expect(
          state.callbackMessage,
          KaziLocalizations.current.errorUnknowError,
        );
      },
    );
  });

  group('Add Service', () {
    const quantityServices = 3;

    test('transitions to loading and then success, clearing state', () async {
      when(
        servicesRepository.add(any, any),
      ).thenAnswer((_) async => servicesMock);

      final provider = serviceFormControllerProvider();
      await container.read(provider.future);

      final emitted = <ServiceFormState>[];
      final sub = container.listen<AsyncValue<ServiceFormState>>(provider, (
        _,
        next,
      ) {
        final value = next.asData?.value;
        if (value != null) emitted.add(value);
      });

      final controller = container.read(provider.notifier);
      controller.onChangeService(serviceMock);
      controller.onChangeServicesQuantity(quantityServices.toString());
      await controller.addService();

      sub.close();

      expect(emitted.any((s) => s.status == BaseStateStatus.loading), isTrue);
      expect(emitted.last.status, BaseStateStatus.success);
      expect(emitted.last.quantity, 1);
      expect(emitted.last.service.userId, authService.user!.uid);
      verify(servicesRepository.add(any, quantityServices)).called(1);
    });
  });

  group('Update Service', () {
    test('transitions to loading and then success, clearing state', () async {
      when(servicesRepository.update(any)).thenAnswer((_) async {});

      final provider = serviceFormControllerProvider(service: serviceMock);
      await container.read(provider.future);

      final emitted = <ServiceFormState>[];
      final sub = container.listen<AsyncValue<ServiceFormState>>(provider, (
        _,
        next,
      ) {
        final value = next.asData?.value;
        if (value != null) emitted.add(value);
      });

      final controller = container.read(provider.notifier);
      await controller.updateService();

      sub.close();

      expect(emitted.any((s) => s.status == BaseStateStatus.loading), isTrue);
      expect(emitted.last.status, BaseStateStatus.success);
      verify(servicesRepository.update(any)).called(1);
    });
  });

  group('Change properties', () {
    const newDiscountPercent = 1.0;
    const newValue = 99.0;
    const newDescription = 'new description';
    final newDateTime = DateTime.now();

    test('updates date', () async {
      final provider = serviceFormControllerProvider();
      await container.read(provider.future);

      final controller = container.read(provider.notifier);
      controller.onChangeServiceDate(newDateTime);

      final state = container.read(provider).asData?.value;
      expect(state, isNotNull);
      expect(state!.service.date, newDateTime);
    });

    test('updates description', () async {
      final provider = serviceFormControllerProvider(service: serviceMock);
      await container.read(provider.future);

      final controller = container.read(provider.notifier);
      controller.onChangeServiceDescription(newDescription);

      final state = container.read(provider).asData?.value;
      expect(state, isNotNull);
      expect(state!.service.description, newDescription);
    });

    test('updates value', () async {
      final provider = serviceFormControllerProvider(service: serviceMock);
      await container.read(provider.future);

      final controller = container.read(provider.notifier);
      controller.onChangeServiceValue(newValue);

      final state = container.read(provider).asData?.value;
      expect(state, isNotNull);
      expect(state!.service.value, newValue);
    });

    test('updates discount percent', () async {
      final provider = serviceFormControllerProvider(service: serviceMock);
      await container.read(provider.future);

      final controller = container.read(provider.notifier);
      controller.onChangeServiceDiscount(newDiscountPercent);

      final state = container.read(provider).asData?.value;
      expect(state, isNotNull);
      expect(state!.service.discountPercent, newDiscountPercent);
    });
  });
}
