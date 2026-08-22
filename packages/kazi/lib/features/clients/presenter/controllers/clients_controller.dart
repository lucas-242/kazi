import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'clients_state.dart';

part 'clients_controller.g.dart';

@Riverpod(keepAlive: true)
class ClientsController extends _$ClientsController
    with BaseNotifier<ClientsState> {
  static const int _pageSize = 10;

  ClientsRepository get _clientsRepository =>
      ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  String get _ownerId => _authService.user!.uid;

  @override
  ClientsState build() => ClientsState(status: BaseStateStatus.loading);

  Future<void> onInit() async {
    try {
      state = state.copyWith(status: BaseStateStatus.loading, query: '');
      final clients = await _clientsRepository.getClients(_ownerId);
      state = state.copyWith(
        status: clients.isEmpty
            ? BaseStateStatus.noData
            : BaseStateStatus.success,
        clients: clients,
        hasReachedMax: clients.length < _pageSize,
      );
      await _loadTotalCount();
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> onRefresh() => onInit();

  /// The header count covers every active client, so it cannot be derived from
  /// the loaded page. A failure here leaves it unset rather than taking the
  /// listing down with it.
  Future<void> _loadTotalCount() async {
    try {
      final total = await _clientsRepository.count(_ownerId);
      state = state.copyWith(totalCount: total);
    } catch (_) {
      // Already logged by the repository.
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax ||
        state.status == BaseStateStatus.loading ||
        state.query.isNotEmpty) {
      return;
    }

    try {
      final lastName = state.clients.isNotEmpty
          ? state.clients.last.info.user.name
          : null;
      final newClients = await _clientsRepository.getClients(
        _ownerId,
        startAfterName: lastName,
      );
      state = state.copyWith(
        status: BaseStateStatus.success,
        clients: [...state.clients, ...newClients],
        hasReachedMax: newClients.length < _pageSize,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> onSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await onInit();
      return;
    }

    try {
      state = state.copyWith(status: BaseStateStatus.loading, query: trimmed);
      final clients = await _clientsRepository.searchByName(_ownerId, trimmed);
      state = state.copyWith(
        status: clients.isEmpty
            ? BaseStateStatus.noData
            : BaseStateStatus.success,
        clients: clients,
        hasReachedMax: true,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _clientsRepository.deactivate(clientId);
      final updated = state.clients
          .where((client) => client.id != clientId)
          .toList();
      final total = state.totalCount;
      state = state.copyWith(
        status: updated.isEmpty
            ? BaseStateStatus.noData
            : BaseStateStatus.success,
        clients: updated,
        totalCount: total == null ? null : (total - 1).clamp(0, total),
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Appends a just-created client to the loaded list in name-sorted position
  /// (used by the service form's quick-add) so it shows up without a refetch.
  /// While loading or in search mode only the total count moves — a later
  /// refresh reconciles the list's order.
  void appendClient(ClientEntry entry) {
    if (state.clients.any((client) => client.id == entry.id)) return;

    final total = state.totalCount;
    final counted = total == null ? null : total + 1;

    if (state.status == BaseStateStatus.loading || state.query.isNotEmpty) {
      state = state.copyWith(totalCount: counted);
      return;
    }

    final updated = [...state.clients, entry]
      ..sort((a, b) => a.info.user.name.compareTo(b.info.user.name));
    state = state.copyWith(
      status: BaseStateStatus.success,
      clients: updated,
      totalCount: counted,
    );
  }

  /// Replaces an already-loaded client in memory (used after an edit) so the
  /// list reflects the new data without refetching from the backend.
  void replaceClient(ClientEntry entry) {
    final updated = [
      for (final client in state.clients)
        if (client.id == entry.id) entry else client,
    ];
    state = state.copyWith(status: BaseStateStatus.success, clients: updated);
  }
}
