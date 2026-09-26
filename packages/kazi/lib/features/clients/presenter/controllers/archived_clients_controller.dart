import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'archived_clients_state.dart';

part 'archived_clients_controller.g.dart';

@riverpod
class ArchivedClientsController extends _$ArchivedClientsController
    with BaseNotifier<ArchivedClientsState> {
  ClientsRepository get _clientsRepository =>
      ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  String get _ownerId => _authService.user!.uid;

  @override
  ArchivedClientsState build() =>
      ArchivedClientsState(status: BaseStateStatus.loading);

  Future<void> onInit() async {
    try {
      final clients = await _clientsRepository.getArchivedClients(_ownerId);

      final counts = <String, int>{};
      for (final client in clients) {
        counts[client.id] = await _clientsRepository.countServicesOf(
          _ownerId,
          client.id,
        );
      }

      state = state.copyWith(
        status: BaseStateStatus.readyToUserInput,
        clients: clients,
        serviceCounts: counts,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> restoreClient(ClientEntry client) async {
    await ref
        .read(clientsControllerProvider.notifier)
        .restoreClient(client, source: 'archived_screen');
    _drop(client.id);
  }

  Future<void> deleteClient(ClientEntry client) async {
    await ref.read(clientsControllerProvider.notifier).deleteClient(client.id);
    _drop(client.id);
  }

  void _drop(String clientId) {
    state = state.copyWith(
      clients: state.clients.where((c) => c.id != clientId).toList(),
      serviceCounts: Map<String, int>.from(state.serviceCounts)
        ..remove(clientId),
    );
  }
}
