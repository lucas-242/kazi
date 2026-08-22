import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/client_mocks.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import 'client_details_controller_test.mocks.dart';

@GenerateMocks([ClientsRepository, AuthService])
void main() {
  const clientId = 'client-1';
  const pageSize = 15;

  late MockClientsRepository clientsRepository;
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

  List<ServiceHistoryItem> history(int count, {int startAt = 0}) => [
    for (var index = startAt; index < startAt + count; index++)
      ServiceHistoryItem(
        serviceName: 'Service $index',
        professionalName: 'Pro',
        // Newest first, mirroring the repository's ordering.
        date: DateTime(2026, 6).subtract(Duration(days: index)),
      ),
  ];

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

  group('build', () {
    test('loads the client and its first page of history', () async {
      final entry = clientEntryMock(
        id: clientId,
        name: 'Ana',
        serviceHistory: history(pageSize),
      );
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer((_) async => entry);

      await mount();

      expect(state().status, BaseStateStatus.success);
      expect(state().client, entry);
      expect(state().serviceHistory, hasLength(pageSize));
      expect(state().hasReachedMaxServices, isFalse);
      verify(
        clientsRepository.getClientDetails(
          userMock.uid,
          clientId,
          limit: pageSize,
        ),
      ).called(1);
    });

    test('marks the history as complete on a partial page', () async {
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer(
        (_) async => clientEntryMock(id: clientId, serviceHistory: history(2)),
      );

      await mount();

      expect(state().hasReachedMaxServices, isTrue);
    });

    test('reports noData when the client does not exist', () async {
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer((_) async => null);

      await mount();

      expect(state().status, BaseStateStatus.noData);
      expect(state().client, isNull);
      expect(state().serviceHistory, isEmpty);
    });

    test('surfaces a failure as an error state', () async {
      // Thrown asynchronously, the way a real repository fails: a synchronous
      // throw would reach `unexpectedError` before `build` had set any state.
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer((_) async => throw Exception('boom'));

      await mount();

      expect(state().status, BaseStateStatus.error);
      expect(
        state().callbackMessage,
        KaziLocalizations.current.errorUnknowError,
      );
    });
  });

  group('loadMoreServices', () {
    Future<void> loadFullFirstPage() async {
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer(
        (_) async =>
            clientEntryMock(id: clientId, serviceHistory: history(pageSize)),
      );
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
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer(
        (_) async => clientEntryMock(id: clientId, serviceHistory: history(2)),
      );
      await mount();

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
      when(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).thenAnswer((_) async => clientEntryMock(id: clientId, name: 'Ana'));
      await mount();

      controller().setClient(clientEntryMock(id: clientId, name: 'Ana Maria'));

      expect(state().client!.info.user.name, 'Ana Maria');
      expect(state().status, BaseStateStatus.success);
      // Only the initial load — the edit never goes back to the backend.
      verify(
        clientsRepository.getClientDetails(any, any, limit: anyNamed('limit')),
      ).called(1);
    });
  });
}
