import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/archived_clients_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/archived_clients_state.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/client_mocks.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../utils/fakes/fake_analytics_service.dart';
import '../../../../../utils/test_helper.dart';
import 'archived_clients_controller_test.mocks.dart';

@GenerateMocks([ClientsRepository, AuthService])
void main() {
  late MockClientsRepository clientsRepository;
  late MockAuthService authService;
  late ProviderContainer container;

  TestHelper.loadAppLocalizations();

  ArchivedClientsController controller() =>
      container.read(archivedClientsControllerProvider.notifier);
  ArchivedClientsState state() =>
      container.read(archivedClientsControllerProvider);

  final archived = [
    clientEntryMock(id: '1', name: 'Ana', archivedAt: DateTime(2026, 8, 24)),
    clientEntryMock(id: '2', name: 'Bruna', archivedAt: DateTime(2026, 8, 25)),
  ];

  setUp(() {
    clientsRepository = MockClientsRepository();
    authService = MockAuthService();

    when(authService.user).thenReturn(userMock);
    when(
      clientsRepository.getArchivedClients(
        any,
        limit: anyNamed('limit'),
        startAfterName: anyNamed('startAfterName'),
      ),
    ).thenAnswer((_) async => archived);
    when(
      clientsRepository.countServicesOf(any, '1'),
    ).thenAnswer((_) async => 3);
    when(
      clientsRepository.countServicesOf(any, '2'),
    ).thenAnswer((_) async => 0);
    when(clientsRepository.delete(any)).thenAnswer((_) async {});
    when(clientsRepository.restore(any)).thenAnswer((_) async {});
    when(clientsRepository.countActive(any)).thenAnswer((_) async => 0);
    when(clientsRepository.countArchived(any)).thenAnswer((_) async => 2);

    container = ProviderContainer(
      overrides: [
        clientsRepositoryProvider.overrideWithValue(clientsRepository),
        authServiceProvider.overrideWithValue(authService),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('onInit', () {
    test('loads the archived clients with their service counts', () async {
      await controller().onInit();

      expect(state().status, BaseStateStatus.readyToUserInput);
      expect(state().clients.map((client) => client.id), ['1', '2']);
      expect(state().countFor('1'), 3);
      expect(state().countFor('2'), 0);
    });

    test('reports a failure without taking the screen down', () async {
      when(
        clientsRepository.getArchivedClients(
          any,
          limit: anyNamed('limit'),
          startAfterName: anyNamed('startAfterName'),
        ),
      ).thenThrow(Exception('boom'));

      await controller().onInit();

      expect(state().status, BaseStateStatus.error);
    });
  });

  group('deleteClient', () {
    test('deletes a client who still has services', () async {
      // The count informs the screen; it never gates the deletion. A person
      // asking to be removed is usually one already served.
      await controller().onInit();

      await controller().deleteClient(archived.first);

      verify(clientsRepository.delete('1')).called(1);
      expect(state().clients.map((client) => client.id), ['2']);
      expect(state().countFor('1'), isNull);
    });

    test('deletes a client with no services', () async {
      await controller().onInit();

      await controller().deleteClient(archived.last);

      verify(clientsRepository.delete('2')).called(1);
      expect(state().clients.map((client) => client.id), ['1']);
    });
  });

  group('restoreClient', () {
    test('restores and drops the client from the archive', () async {
      await controller().onInit();

      await controller().restoreClient(archived.first);

      verify(clientsRepository.restore('1')).called(1);
      expect(state().clients.map((client) => client.id), ['2']);
    });
  });
}
