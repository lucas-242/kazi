import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository, Service;
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fake_creation_ad_coordinator.dart';
import '../../../../../utils/fake_subscription_service.dart';
import '../../../../../utils/test_helper.dart';
import 'service_form_controller_test.mocks.dart';

@GenerateMocks([
  ServiceTypeRepository,
  ServicesRepository,
  ClientsRepository,
  AuthService,
  KaziInAppReviewManager,
])
void main() {
  late MockServiceTypeRepository serviceTypeRepository;
  late MockServicesRepository servicesRepository;
  late MockClientsRepository clientsRepository;
  late MockAuthService authService;
  late MockKaziInAppReviewManager inAppReviewManager;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  setUp(() async {
    serviceTypeRepository = MockServiceTypeRepository();
    servicesRepository = MockServicesRepository();
    clientsRepository = MockClientsRepository();
    authService = MockAuthService();
    inAppReviewManager = MockKaziInAppReviewManager();

    when(authService.user).thenReturn(userMock);

    when(
      serviceTypeRepository.get(any),
    ).thenAnswer((_) async => serviceTypesMock);

    when(
      clientsRepository.getClients(
        any,
        limit: anyNamed('limit'),
        startAfterName: anyNamed('startAfterName'),
      ),
    ).thenAnswer((_) async => []);

    when(inAppReviewManager.onServiceCreated()).thenAnswer((_) async {
      return;
    });
    when(inAppReviewManager.onAppStarted()).thenAnswer((_) async {
      return;
    });

    container = ProviderContainer(
      overrides: [
        servicesRepositoryProvider.overrideWithValue(servicesRepository),
        serviceTypeRepositoryProvider.overrideWithValue(serviceTypeRepository),
        clientsRepositoryProvider.overrideWithValue(clientsRepository),
        authServiceProvider.overrideWithValue(authService),
        subscriptionServiceProvider.overrideWithValue(
          FakeSubscriptionService(),
        ),
        freemiumGuardProvider.overrideWithValue(fakeFreemiumGuard()),
        inAppReviewManagerProvider.overrideWith(
          (ref) => Future.value(inAppReviewManager),
        ),
        creationAdCoordinatorProvider.overrideWith(
          (ref) => FakeCreationAdCoordinator(),
        ),
      ],
    );
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

    test(
      'stays readyToUserInput when serviceTypes is empty (inline quick-add)',
      () async {
        when(serviceTypeRepository.get(any)).thenAnswer((_) async => []);

        final provider = serviceFormControllerProvider();
        final state = await container.read(provider.future);

        expect(state.status, BaseStateStatus.readyToUserInput);
        expect(state.serviceTypes, isEmpty);
      },
    );

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

  group('Quick add service type', () {
    test('appends the created type in place and auto-selects it', () async {
      final created = serviceTypeMock.copyWith(
        id: 'new-type-id',
        name: 'Barber',
        defaultValue: 42,
        discountPercent: 5,
      );
      when(serviceTypeRepository.add(any)).thenAnswer((_) async => created);

      final provider = serviceFormControllerProvider();
      await container.read(provider.future);

      final controller = container.read(provider.notifier);
      await controller.quickAddServiceType(
        name: 'Barber',
        defaultValue: 42,
        discountPercent: 5,
      );

      final state = container.read(provider).asData?.value;
      expect(state, isNotNull);
      expect(state!.serviceTypes.contains(created), isTrue);
      expect(state.service.typeId, created.id);
      expect(state.service.value, created.defaultValue);
      expect(state.service.discountPercent, created.discountPercent);
      // The list was appended in place: get() was only called once, at build.
      verify(serviceTypeRepository.get(any)).called(1);
    });

    test('throws when the name duplicates an existing type', () async {
      final provider = serviceFormControllerProvider();
      await container.read(provider.future);

      final controller = container.read(provider.notifier);

      expect(
        () => controller.quickAddServiceType(name: serviceTypesMock.first.name),
        throwsA(isA<AppError>()),
      );
      verifyNever(serviceTypeRepository.add(any));
    });
  });

  group('Quick add client', () {
    test('appends the created client in place and auto-selects it', () async {
      when(
        clientsRepository.add(any, any),
      ).thenAnswer((_) async => 'new-client-id');

      final provider = serviceFormControllerProvider();
      await container.read(provider.future);

      final controller = container.read(provider.notifier);
      await controller.quickAddClient(
        identifier: '12345678900',
        name: 'Ada Lovelace',
        phone: '+551199999999',
      );

      final state = container.read(provider).asData?.value;
      expect(state, isNotNull);
      expect(state!.clients.length, 1);
      expect(state.clients.first.id, 'new-client-id');
      expect(state.clients.first.info.user.name, 'Ada Lovelace');
      expect(state.service.clientId, 'new-client-id');
      expect(state.service.clientName, 'Ada Lovelace');
    });

    test('throws when a required field is empty', () async {
      final provider = serviceFormControllerProvider();
      await container.read(provider.future);

      final controller = container.read(provider.notifier);

      expect(
        () => controller.quickAddClient(
          identifier: '',
          name: 'Ada',
          phone: '123',
        ),
        throwsA(isA<AppError>()),
      );
      verifyNever(clientsRepository.add(any, any));
    });
  });
}
