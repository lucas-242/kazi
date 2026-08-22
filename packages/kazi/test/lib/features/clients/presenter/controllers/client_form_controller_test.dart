import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/client_form_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_form_state.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../utils/fakes/fake_analytics_service.dart';

import '../../../../../mocks/client_mocks.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fake_creation_ad_coordinator.dart';
import '../../../../../utils/fake_subscription_service.dart';
import '../../../../../utils/test_helper.dart';
import 'client_form_controller_test.mocks.dart';

@GenerateMocks([ClientsRepository, AuthService])
void main() {
  late MockClientsRepository clientsRepository;
  late MockAuthService authService;
  late FakeCreationAdCoordinator creationAdCoordinator;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  /// Mounts the form and keeps it mounted.
  ///
  /// The controller is auto-disposed, so without a live subscription each
  /// `container.read` would tear it down again and the next one would hand back
  /// a freshly built, empty form — losing every `onChange` the test made.
  void keepAlive({ClientEntry? client}) =>
      container.listen(clientFormControllerProvider(client: client), (_, _) {});

  /// Builds a container whose freemium guard reports [existingClients] already
  /// created, for a user on the given tier.
  void buildContainer({
    int existingClients = 0,
    Entitlement entitlement = const Entitlement(
      isPremium: true,
      isInGracePeriod: false,
      willRenew: true,
      isTrial: false,
      hasPaidBefore: true,
    ),
  }) {
    container = ProviderContainer(
      overrides: [
        clientsRepositoryProvider.overrideWithValue(clientsRepository),
        // The creation path reports `client_created` / `limit_reached`.
        // Without this the real composite is built, and its Firebase sink
        // needs an initialised Firebase app a unit test does not have.
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        authServiceProvider.overrideWithValue(authService),
        subscriptionServiceProvider.overrideWithValue(
          FakeSubscriptionService(entitlement: entitlement),
        ),
        freemiumGuardProvider.overrideWithValue(
          fakeFreemiumGuard(entitlement: entitlement, clients: existingClients),
        ),
        creationAdCoordinatorProvider.overrideWith(
          (ref) async => creationAdCoordinator,
        ),
      ],
    );
    keepAlive();
  }

  ClientFormController controller({ClientEntry? client}) =>
      container.read(clientFormControllerProvider(client: client).notifier);
  ClientFormState state({ClientEntry? client}) =>
      container.read(clientFormControllerProvider(client: client)).requireValue;

  setUp(() {
    clientsRepository = MockClientsRepository();
    authService = MockAuthService();
    creationAdCoordinator = FakeCreationAdCoordinator();

    when(authService.user).thenReturn(userMock);
    when(clientsRepository.add(any, any)).thenAnswer((_) async => 'new-id');
    when(
      clientsRepository.update(any, any),
    ).thenAnswer((_) => Future<void>.value());
    // Saving an edit pushes the new entry into the details controller, whose
    // own build fetches the client — stubbed here so every edit test does not
    // have to.
    when(
      clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
    ).thenAnswer((_) async => null);

    buildContainer();
  });

  tearDown(() => container.dispose());

  /// Fills every required field so a test only has to state what it changes.
  void fillRequiredFields(ClientFormController target) {
    target
      ..onChangeName('Ana')
      ..onChangePhone('11999999999')
      ..onChangeIdentifier('12345678900');
  }

  group('build', () {
    test('starts empty and ready when adding', () {
      expect(state().status, BaseStateStatus.readyToUserInput);
      expect(state().isEditing, isFalse);
      expect(state().name, '');
      expect(state().clientId, isNull);
      expect(state().birthDate, isNull);
    });

    test('prefills from the client being edited', () {
      final entry = clientEntryMock(
        id: 'client-1',
        name: 'Ana',
        email: 'ana@test.com',
        phones: ['11999999999'],
      );

      final current = state(client: entry);

      expect(current.isEditing, isTrue);
      expect(current.clientId, 'client-1');
      expect(current.name, 'Ana');
      expect(current.email, 'ana@test.com');
      expect(current.phone, '11999999999');
    });

    test('keeps a real stored birth date', () {
      final entry = clientEntryMock(id: 'client-1', birthDate: DateTime(1990));

      expect(state(client: entry).birthDate, DateTime(1990));
    });

    test('drops the DateTime(2000) placeholder birth date', () {
      // What a client stored without a birth date carries — it is an absence,
      // not a date, and must not be shown as one.
      final entry = clientEntryMock(id: 'client-1', birthDate: DateTime(2000));

      expect(state(client: entry).birthDate, isNull);
    });
  });

  group('onChange', () {
    test('each field lands in the state', () {
      controller()
        ..onChangeName('Ana')
        ..onChangePhone('11999999999')
        ..onChangeEmail('ana@test.com')
        ..onChangeIdentifier('12345678900')
        ..onChangeBirthDate(DateTime(1995, 3, 20));

      expect(state().name, 'Ana');
      expect(state().phone, '11999999999');
      expect(state().email, 'ana@test.com');
      expect(state().identifier, '12345678900');
      expect(state().birthDate, DateTime(1995, 3, 20));
    });
  });

  group('save — validation', () {
    test('refuses an empty identifier', () async {
      controller()
        ..onChangeName('Ana')
        ..onChangePhone('11999999999');

      await controller().save();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.document,
        ),
      );
      verifyNever(clientsRepository.add(any, any));
    });

    test('refuses an empty name', () async {
      controller()
        ..onChangePhone('11999999999')
        ..onChangeIdentifier('12345678900');

      await controller().save();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.name,
        ),
      );
    });

    test('refuses an empty phone', () async {
      controller()
        ..onChangeName('Ana')
        ..onChangeIdentifier('12345678900');

      await controller().save();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.phone,
        ),
      );
    });

    test('treats whitespace-only input as empty', () async {
      controller()
        ..onChangeName('   ')
        ..onChangePhone('11999999999')
        ..onChangeIdentifier('12345678900');

      await controller().save();

      expect(state().status, BaseStateStatus.error);
    });
  });

  group('save — creating', () {
    test('writes a trimmed client and reports success', () async {
      controller()
        ..onChangeName('  Ana  ')
        ..onChangePhone('  11999999999  ')
        ..onChangeEmail('  ana@test.com ')
        ..onChangeIdentifier(' 12345678900 ');

      await controller().save();

      final captured =
          verify(
                clientsRepository.add(userMock.uid, captureAny),
              ).captured.single
              as User;
      expect(captured.name, 'Ana');
      expect(captured.email, 'ana@test.com');
      expect(captured.identifier, '12345678900');
      expect(captured.phones, ['11999999999']);
      expect(captured.userType, UserType.client);
      expect(state().status, BaseStateStatus.success);
    });

    test('appends the new client to the loaded list', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(1));
      await container.read(clientsControllerProvider.notifier).onInit();

      fillRequiredFields(controller());
      await controller().save();

      final listed = container.read(clientsControllerProvider).clients;
      expect(listed.map((client) => client.id), contains('new-id'));
    });

    test('counts the creation towards the interstitial cadence', () async {
      fillRequiredFields(controller());

      await controller().save();

      expect(creationAdCoordinator.creationActions, 1);
    });

    test('surfaces a write failure without leaving the form loading', () async {
      when(clientsRepository.add(any, any)).thenThrow(Exception('boom'));
      fillRequiredFields(controller());

      await controller().save();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('save — freemium gate', () {
    test('blocks the write and prompts the paywall at the limit', () async {
      // A never-paid user is capped at five clients.
      buildContainer(existingClients: 5, entitlement: const Entitlement.free());
      fillRequiredFields(controller());

      await controller().save();

      verifyNever(clientsRepository.add(any, any));
      expect(
        container.read(paywallPromptControllerProvider),
        LimitType.clients,
      );
      expect(creationAdCoordinator.creationActions, 0);
    });

    test('lets a free user under the limit through', () async {
      buildContainer(entitlement: const Entitlement.free());
      fillRequiredFields(controller());

      await controller().save();

      verify(clientsRepository.add(any, any)).called(1);
      expect(container.read(paywallPromptControllerProvider), isNull);
    });

    test('never gates an edit', () async {
      buildContainer(
        existingClients: 50,
        entitlement: const Entitlement.free(),
      );
      final entry = clientEntryMock(id: 'client-1', phones: ['11999999999']);
      keepAlive(client: entry);
      controller(client: entry)
        ..onChangeName('Ana Maria')
        ..onChangeIdentifier('12345678900');

      await controller(client: entry).save();

      verify(clientsRepository.update('client-1', any)).called(1);
      expect(container.read(paywallPromptControllerProvider), isNull);
    });
  });

  group('save — editing', () {
    final entry = clientEntryMock(
      id: 'client-1',
      name: 'Ana',
      phones: ['11999999999'],
      lastServiceName: 'Manicure',
      serviceHistory: [
        ServiceHistoryItem(
          serviceName: 'Manicure',
          professionalName: 'Pro',
          date: DateTime(2026, 5),
        ),
      ],
    );

    setUp(() => keepAlive(client: entry));

    test('updates instead of adding', () async {
      controller(client: entry)
        ..onChangeName('Ana Maria')
        ..onChangeIdentifier('12345678900');

      await controller(client: entry).save();

      verify(clientsRepository.update('client-1', any)).called(1);
      verifyNever(clientsRepository.add(any, any));
      expect(state(client: entry).status, BaseStateStatus.success);
    });

    test('an edit does not count towards the ad cadence', () async {
      controller(client: entry).onChangeIdentifier('12345678900');

      await controller(client: entry).save();

      expect(creationAdCoordinator.creationActions, 0);
    });

    test('preserves the denormalized history the form never sees', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => [entry]);
      await container.read(clientsControllerProvider.notifier).onInit();

      controller(client: entry)
        ..onChangeName('Ana Maria')
        ..onChangeIdentifier('12345678900');
      await controller(client: entry).save();

      final updated = container
          .read(clientsControllerProvider)
          .clients
          .firstWhere((client) => client.id == 'client-1');
      expect(updated.info.user.name, 'Ana Maria');
      expect(updated.info.lastServiceName, 'Manicure');
      expect(updated.info.serviceHistory, hasLength(1));
    });
  });
}
