import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/client_mocks.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'clients_controller_test.mocks.dart';

@GenerateMocks([ClientsRepository, AuthService])
void main() {
  late MockClientsRepository clientsRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  ClientsController controller() =>
      container.read(clientsControllerProvider.notifier);
  ClientsState state() => container.read(clientsControllerProvider);

  setUp(() {
    clientsRepository = MockClientsRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);

    container = ProviderContainer(
      overrides: [
        clientsRepositoryProvider.overrideWithValue(clientsRepository),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('onInit', () {
    test('loads the first page and reports success', () async {
      final clients = clientEntriesMock(10);
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clients);

      await controller().onInit();

      expect(state().status, BaseStateStatus.success);
      expect(state().clients, clients);
      expect(state().query, '');
    });

    test('reports noData when the user has no clients', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => []);

      await controller().onInit();

      expect(state().status, BaseStateStatus.noData);
      expect(state().clients, isEmpty);
    });

    test('marks the end of the list when a partial page comes back', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(3));

      await controller().onInit();

      expect(state().hasReachedMax, isTrue);
    });

    test('leaves hasReachedMax false on a full page', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(10));

      await controller().onInit();

      expect(state().hasReachedMax, isFalse);
    });

    test('clears a previous search query', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => clientEntriesMock(1));
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(10));

      await controller().onSearch('Client');
      expect(state().query, 'Client');

      await controller().onInit();
      expect(state().query, '');
    });

    test('surfaces an unexpected failure as an error state', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenThrow(Exception('boom'));

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('loadMore', () {
    setUp(() {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(10));
    });

    test('appends the next page after the loaded ones', () async {
      await controller().onInit();

      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(10, startAt: 10));

      await controller().loadMore();

      expect(state().clients, hasLength(20));
      expect(state().clients.first.id, '0');
      expect(state().clients.last.id, '19');
    });

    test('pages from the last loaded name', () async {
      await controller().onInit();
      final lastName = state().clients.last.info.user.name;

      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => []);

      await controller().loadMore();

      verify(
        clientsRepository.getClients(userMock.uid, startAfterName: lastName),
      ).called(1);
    });

    test('does nothing once the end of the list is known', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(3));
      await controller().onInit();
      clearInteractions(clientsRepository);

      await controller().loadMore();

      verifyNever(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      );
    });

    test('does nothing while a search is active', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => clientEntriesMock(10));
      await controller().onSearch('Client');
      clearInteractions(clientsRepository);

      await controller().loadMore();

      verifyNever(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      );
    });

    test('surfaces a failure without dropping the loaded page', () async {
      await controller().onInit();

      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenThrow(Exception('boom'));

      await controller().loadMore();

      expect(state().status, BaseStateStatus.error);
      expect(state().clients, hasLength(10));
    });
  });

  group('onSearch', () {
    test('replaces the list with the matches and closes paging', () async {
      final matches = clientEntriesMock(2);
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => matches);

      await controller().onSearch('Client');

      expect(state().status, BaseStateStatus.success);
      expect(state().clients, matches);
      expect(state().query, 'Client');
      expect(state().hasReachedMax, isTrue);
    });

    test('reports noData when nothing matches', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => []);

      await controller().onSearch('nobody');

      expect(state().status, BaseStateStatus.noData);
    });

    test('trims the query before searching', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => clientEntriesMock(1));

      await controller().onSearch('  Ana  ');

      verify(clientsRepository.searchByName(userMock.uid, 'Ana')).called(1);
      expect(state().query, 'Ana');
    });

    test('an empty query falls back to the full list', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(10));

      await controller().onSearch('   ');

      verifyNever(clientsRepository.searchByName(any, any));
      verify(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).called(1);
      expect(state().query, '');
    });

    test('surfaces a failure as an error state', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenThrow(Exception('boom'));

      await controller().onSearch('Ana');

      expect(state().status, BaseStateStatus.error);
    });
  });

  group('deleteClient', () {
    setUp(() {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(3));
      when(
        clientsRepository.deactivate(any),
      ).thenAnswer((_) => Future<void>.value());
    });

    test('deactivates the client and drops it from the list', () async {
      await controller().onInit();

      await controller().deleteClient('1');

      verify(clientsRepository.deactivate('1')).called(1);
      expect(state().clients.map((client) => client.id), ['0', '2']);
      expect(state().status, BaseStateStatus.success);
    });

    test('falls back to noData when the last client goes', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(1));
      await controller().onInit();

      await controller().deleteClient('0');

      expect(state().status, BaseStateStatus.noData);
      expect(state().clients, isEmpty);
    });

    test('keeps the list intact when the deletion fails', () async {
      await controller().onInit();
      when(clientsRepository.deactivate(any)).thenThrow(Exception('boom'));

      await controller().deleteClient('1');

      expect(state().status, BaseStateStatus.error);
      expect(state().clients, hasLength(3));
    });
  });

  group('appendClient', () {
    setUp(() {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer(
        (_) async => [
          clientEntryMock(id: '1', name: 'Ana'),
          clientEntryMock(id: '3', name: 'Carla'),
        ],
      );
    });

    test('inserts in name order', () async {
      await controller().onInit();

      controller().appendClient(clientEntryMock(id: '2', name: 'Bruna'));

      expect(state().clients.map((client) => client.info.user.name), [
        'Ana',
        'Bruna',
        'Carla',
      ]);
    });

    test('ignores a client already in the list', () async {
      await controller().onInit();

      controller().appendClient(clientEntryMock(id: '1', name: 'Ana'));

      expect(state().clients, hasLength(2));
    });

    test('no-ops while loading', () {
      controller().appendClient(clientEntryMock(id: '9', name: 'Zoe'));

      expect(state().clients, isEmpty);
    });

    test('no-ops while a search is active', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => [clientEntryMock(id: '1', name: 'Ana')]);
      await controller().onSearch('Ana');

      controller().appendClient(clientEntryMock(id: '9', name: 'Zoe'));

      expect(state().clients, hasLength(1));
    });
  });

  group('replaceClient', () {
    test('swaps the matching client and leaves the rest alone', () async {
      when(
        clientsRepository.getClients(
          any,
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenAnswer((_) async => clientEntriesMock(3));
      await controller().onInit();

      controller().replaceClient(clientEntryMock(id: '1', name: 'Renamed'));

      expect(state().clients.map((client) => client.info.user.name), [
        'Client 00',
        'Renamed',
        'Client 02',
      ]);
    });
  });
}
