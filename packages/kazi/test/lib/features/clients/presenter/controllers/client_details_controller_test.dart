import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/client_mocks.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'client_details_controller_test.mocks.dart';

@GenerateMocks([ClientsRepository, CatalogItemRepository, AuthService])
void main() {
  const clientId = 'client-1';
  const pageSize = 15;

  late MockClientsRepository clientsRepository;
  late MockCatalogItemRepository catalogItemRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  final provider = clientDetailsControllerProvider(clientId: clientId);

  ClientDetailsController controller() => container.read(provider.notifier);
  ClientDetailsState state() => container.read(provider);

  /// Mounts the controller and lets its `build`-time load settle.
  ///
  /// The subscription is what keeps it mounted: this controller is
  /// auto-disposed, so a bare `container.read` would tear it down again the
  /// moment the read returns and the next read would restart the load.
  /// Every test stubs the repository first, then calls this.
  Future<void> mount() async {
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
  }

  List<Service> history(int count, {int startAt = 0}) => [
    for (var index = startAt; index < startAt + count; index++)
      Service(
        id: 'service-$index',
        userId: userMock.uid,
        // Newest first, mirroring the repository's ordering.
        date: DateTime(2026, 6).subtract(Duration(days: index)),
      ),
  ];

  /// Stubs the two calls `build` makes, in the order it makes them.
  void stubDetails(ClientEntry? entry, {List<Service> services = const []}) {
    when(
      clientsRepository.getClientDetails(any, any),
    ).thenAnswer((_) async => entry);
    when(
      clientsRepository.getServiceHistory(any, any, limit: anyNamed('limit')),
    ).thenAnswer((_) async => services);
    // Only reached when the page does not already end on the oldest service.
    when(
      clientsRepository.getFirstServiceDate(any, any),
    ).thenAnswer((_) async => services.lastOrNull?.date);
  }

  setUp(() {
    clientsRepository = MockClientsRepository();
    catalogItemRepository = MockCatalogItemRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    // The history joins its catalog items, and loads the catalog to do it.
    when(catalogItemRepository.get(any)).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        clientsRepositoryProvider.overrideWithValue(clientsRepository),
        catalogItemRepositoryProvider.overrideWithValue(catalogItemRepository),
        authServiceProvider.overrideWithValue(authService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('build', () {
    test('loads the client and its first page of history', () async {
      final entry = clientEntryMock(id: clientId, name: 'Ana');
      stubDetails(entry, services: history(pageSize));

      await mount();

      expect(state().status, BaseStateStatus.success);
      expect(state().client, entry);
      expect(state().serviceHistory, hasLength(pageSize));
      expect(state().hasReachedMaxServices, isFalse);
      verify(
        clientsRepository.getServiceHistory(
          userMock.uid,
          clientId,
          limit: pageSize,
        ),
      ).called(1);
    });

    test('marks the history as complete on a partial page', () async {
      stubDetails(clientEntryMock(id: clientId), services: history(2));

      await mount();

      expect(state().hasReachedMaxServices, isTrue);
    });

    test('reports noData when the client does not exist', () async {
      stubDetails(null);

      await mount();

      expect(state().status, BaseStateStatus.noData);
      expect(state().client, isNull);
      expect(state().serviceHistory, isEmpty);
    });

    test('surfaces a failure as an error state', () async {
      // Thrown asynchronously, the way a real repository fails: a synchronous
      // throw would reach `unexpectedError` before `build` had set any state.
      when(
        clientsRepository.getClientDetails(any, any),
      ).thenAnswer((_) async => throw Exception('boom'));

      await mount();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('firstServiceDate', () {
    test('takes it off a complete page, without a second query', () async {
      stubDetails(clientEntryMock(id: clientId), services: history(2));

      await mount();

      // The page is ordered newest first, so a complete one ends on the oldest.
      expect(state().firstServiceDate, history(2).last.date);
      verifyNever(clientsRepository.getFirstServiceDate(any, any));
    });

    test('asks for it when there is more history than the page', () async {
      stubDetails(clientEntryMock(id: clientId), services: history(pageSize));
      when(
        clientsRepository.getFirstServiceDate(any, any),
      ).thenAnswer((_) async => DateTime(2020, 3));

      await mount();

      expect(state().firstServiceDate, DateTime(2020, 3));
      verify(
        clientsRepository.getFirstServiceDate(userMock.uid, clientId),
      ).called(1);
    });

    test('leaves it null for a client with no service at all', () async {
      stubDetails(clientEntryMock(id: clientId));

      await mount();

      expect(state().firstServiceDate, isNull);
      verifyNever(clientsRepository.getFirstServiceDate(any, any));
    });
  });

  group('loadMoreServices', () {
    Future<void> loadFullFirstPage() async {
      stubDetails(clientEntryMock(id: clientId), services: history(pageSize));
      await mount();
    }

    test('appends the next page and clears the loading flag', () async {
      await loadFullFirstPage();
      when(
        clientsRepository.getServiceHistory(
          any,
          any,
          limit: anyNamed('limit'),
          startAfterDate: anyNamed('startAfterDate'),
        ),
      ).thenAnswer((_) async => history(5, startAt: pageSize));

      await controller().loadMoreServices();

      expect(state().serviceHistory, hasLength(pageSize + 5));
      expect(state().hasReachedMaxServices, isTrue);
      expect(state().isLoadingMoreServices, isFalse);
    });

    test('pages from the oldest loaded item', () async {
      await loadFullFirstPage();
      final oldest = state().serviceHistory.last.date;
      when(
        clientsRepository.getServiceHistory(
          any,
          any,
          limit: anyNamed('limit'),
          startAfterDate: anyNamed('startAfterDate'),
        ),
      ).thenAnswer((_) async => []);

      await controller().loadMoreServices();

      verify(
        clientsRepository.getServiceHistory(
          userMock.uid,
          clientId,
          limit: pageSize,
          startAfterDate: oldest,
        ),
      ).called(1);
    });

    test('does nothing once the history is complete', () async {
      stubDetails(clientEntryMock(id: clientId), services: history(2));
      await mount();
      // The first page is fetched by `build`; only what comes after it is
      // what this asserts on.
      clearInteractions(clientsRepository);

      await controller().loadMoreServices();

      verifyNever(
        clientsRepository.getServiceHistory(
          any,
          any,
          limit: anyNamed('limit'),
          startAfterDate: anyNamed('startAfterDate'),
        ),
      );
    });

    test('clears the loading flag when the page fails', () async {
      await loadFullFirstPage();
      when(
        clientsRepository.getServiceHistory(
          any,
          any,
          limit: anyNamed('limit'),
          startAfterDate: anyNamed('startAfterDate'),
        ),
      ).thenThrow(Exception('boom'));

      await controller().loadMoreServices();

      expect(state().status, BaseStateStatus.error);
      expect(state().isLoadingMoreServices, isFalse);
      expect(state().serviceHistory, hasLength(pageSize));
    });
  });

  group('setClient', () {
    test('swaps in the edited client without refetching', () async {
      stubDetails(clientEntryMock(id: clientId, name: 'Ana'));
      await mount();

      controller().setClient(clientEntryMock(id: clientId, name: 'Ana Maria'));

      expect(state().client!.info.user.name, 'Ana Maria');
      expect(state().status, BaseStateStatus.success);
      // Only the initial load — the edit never goes back to the backend.
      verify(clientsRepository.getClientDetails(any, any)).called(1);
    });
  });
}
