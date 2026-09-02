import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/models/client_order.dart';
import 'package:kazi/features/clients/domain/models/record_counters.dart';
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
import '../../../../../utils/fakes/fake_analytics_service.dart';
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
    when(clientsRepository.countActive(any)).thenAnswer((_) async => 3);
    when(clientsRepository.countArchived(any)).thenAnswer((_) async => 0);

    container = ProviderContainer(
      overrides: [
        clientsRepositoryProvider.overrideWithValue(clientsRepository),
        authServiceProvider.overrideWithValue(authService),
        // The real composite analytics needs an initialised Firebase app.
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('onInit', () {
    test('loads the first page and reports success', () async {
      final clients = clientEntriesMock(10);
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => clients);

      await controller().onInit();

      expect(state().status, BaseStateStatus.success);
      expect(state().clients, clients);
      expect(state().query, '');
    });

    test('reports noData when the user has no clients', () async {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => []);

      await controller().onInit();

      expect(state().status, BaseStateStatus.noData);
      expect(state().clients, isEmpty);
    });

    test('clears a previous search query', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => clientEntriesMock(1));
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => clientEntriesMock(10));

      await controller().onSearch('Client');
      expect(state().query, 'Client');

      await controller().onInit();
      expect(state().query, '');
    });

    test('surfaces an unexpected failure as an error state', () async {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenThrow(Exception('boom'));

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('onSearch', () {
    test('replaces the list with the matches', () async {
      final matches = clientEntriesMock(2);
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => matches);

      await controller().onSearch('Client');

      expect(state().status, BaseStateStatus.success);
      expect(state().clients, matches);
      expect(state().query, 'Client');
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
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => clientEntriesMock(10));

      await controller().onSearch('   ');

      verifyNever(clientsRepository.searchByName(any, any));
      verify(clientsRepository.getAllActiveClients(any)).called(1);
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

  group('archiveClient', () {
    setUp(() {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => clientEntriesMock(3));
      when(
        clientsRepository.archive(any),
      ).thenAnswer((_) async => DateTime(2026, 8, 24));
    });

    test('archives the client and drops it from the list', () async {
      await controller().onInit();

      final archived = await controller().archiveClient('1');

      expect(archived, isTrue);
      verify(clientsRepository.archive('1')).called(1);
      expect(state().clients.map((client) => client.id), ['0', '2']);
      expect(state().status, BaseStateStatus.success);
    });

    test('moves the client into the archived count', () async {
      await controller().onInit();
      final before = state().archivedCount;

      await controller().archiveClient('1');

      expect(state().archivedCount, before + 1);
    });

    test('falls back to noData when the last client goes', () async {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => clientEntriesMock(1));
      await controller().onInit();

      await controller().archiveClient('0');

      expect(state().status, BaseStateStatus.noData);
      expect(state().clients, isEmpty);
    });

    test('keeps the list intact when archiving fails', () async {
      await controller().onInit();
      when(clientsRepository.archive(any)).thenThrow(Exception('boom'));

      final archived = await controller().archiveClient('1');

      expect(archived, isFalse);
      expect(state().status, BaseStateStatus.error);
      expect(state().clients, hasLength(3));
    });

    test('restoring puts the client back in the list', () async {
      when(clientsRepository.restore(any)).thenAnswer((_) async {});
      await controller().onInit();
      final entry = state().clients.firstWhere((client) => client.id == '1');

      await controller().archiveClient('1');
      await controller().restoreClient(entry);

      verify(clientsRepository.restore('1')).called(1);
      expect(state().clients.map((client) => client.id), ['0', '1', '2']);
      expect(state().archivedCount, 0);
    });
  });

  group('appendClient', () {
    setUp(() {
      when(clientsRepository.getAllActiveClients(any)).thenAnswer(
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

  group('totalCount', () {
    setUp(() {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => clientEntriesMock(3));
      when(
        clientsRepository.archive(any),
      ).thenAnswer((_) async => DateTime(2026, 8, 24));
    });

    test('counts every active client, not just the loaded page', () async {
      when(clientsRepository.countActive(any)).thenAnswer((_) async => 42);

      await controller().onInit();

      expect(state().totalCount, 42);
    });

    test('stays unset when the count fails, keeping the listing', () async {
      when(clientsRepository.countActive(any)).thenThrow(Exception('boom'));

      await controller().onInit();

      expect(state().totalCount, isNull);
      expect(state().status, BaseStateStatus.success);
    });

    test('drops by one when a client is archived', () async {
      await controller().onInit();

      await controller().archiveClient('1');

      expect(state().totalCount, 2);
    });

    test('holds when archiving fails', () async {
      await controller().onInit();
      when(clientsRepository.archive(any)).thenThrow(Exception('boom'));

      await controller().archiveClient('1');

      expect(state().totalCount, 3);
    });

    test('rises by one when a client is added elsewhere', () async {
      await controller().onInit();

      controller().appendClient(clientEntryMock(id: '9', name: 'Zoe'));

      expect(state().totalCount, 4);
    });

    test('rises even while a search hides the new client', () async {
      when(
        clientsRepository.searchByName(any, any),
      ).thenAnswer((_) async => [clientEntryMock(id: '1', name: 'Ana')]);
      await controller().onInit();
      await controller().onSearch('Ana');

      controller().appendClient(clientEntryMock(id: '9', name: 'Zoe'));

      expect(state().totalCount, 4);
      expect(state().clients, hasLength(1));
    });
  });

  // Ordering is not filtering: it never hides anyone. Two of the three are
  // computed here because Firestore cannot sort on them. See core/counters.md.
  group('onChangeOrder', () {
    ClientEntry served(
      String id, {
      required String name,
      required int count,
      required double commission,
      required DateTime lastService,
    }) => clientEntryMock(
      id: id,
      name: name,
      lastServiceDate: lastService,
      counters: RecordCounters(
        count: count,
        byCurrency: {
          'USD': (generated: commission * 2, commission: commission),
        },
      ),
    );

    final marina = served(
      'marina',
      name: 'Marina',
      count: 12,
      commission: 1840,
      lastService: DateTime(2026, 8, 9),
    );
    final julia = served(
      'julia',
      name: 'Julia',
      count: 9,
      commission: 990,
      lastService: DateTime(2026, 8, 20),
    );
    final newcomer = clientEntryMock(id: 'ana', name: 'Ana');

    Future<List<String>> loadedWith(ClientOrder order) async {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => [marina, julia, newcomer]);

      await controller().onInit();
      controller().onChangeOrder(order);

      return state().clients.map((client) => client.id).toList();
    }

    test('orders by the most recent service by default', () async {
      when(
        clientsRepository.getAllActiveClients(any),
      ).thenAnswer((_) async => [marina, julia, newcomer]);

      await controller().onInit();

      expect(state().order, ClientOrder.lastService);
      expect(state().clients.map((client) => client.id), [
        'julia',
        'marina',
        'ana',
      ]);
    });

    test(
      'puts someone with no service last, whatever their stored date',
      () async {
        final result = await loadedWith(ClientOrder.lastService);

        expect(result.last, 'ana');
      },
    );

    test('orders alphabetically without hiding anyone', () async {
      final result = await loadedWith(ClientOrder.alphabetical);

      expect(result, ['ana', 'julia', 'marina']);
    });

    test('orders by lifetime earnings', () async {
      final result = await loadedWith(ClientOrder.topEarning);

      expect(result, ['marina', 'julia', 'ana']);
    });
  });

  group('replaceClient', () {
    test('swaps the matching client and leaves the rest alone', () async {
      when(
        clientsRepository.getAllActiveClients(any),
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
