import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/models/client_order.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi/features/clients/domain/models/record_counters.dart';
import 'package:kazi_core/kazi_core.dart';

import 'clients_state.dart';

part 'clients_controller.g.dart';

@Riverpod(keepAlive: true)
class ClientsController extends _$ClientsController
    with BaseNotifier<ClientsState> {
  ClientsRepository get _clientsRepository =>
      ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  String get _ownerId => _authService.user!.uid;

  @override
  ClientsState build() {
    ref.listen(kaziDefaultCurrencyProvider, (_, next) {
      state = _reordered(state.copyWith(defaultCurrency: next));
    });
    return ClientsState(
      status: BaseStateStatus.loading,
      defaultCurrency: ref.read(kaziDefaultCurrencyProvider),
    );
  }

  Future<void> onInit() async {
    try {
      state = state.copyWith(
        status: BaseStateStatus.loading,
        query: '',
        isSearching: false,
      );
      // Unpaged on purpose: two of the three orderings are computed here, from
      // figures Firestore cannot sort on. See core/counters.md.
      final clients = await _clientsRepository.getAllActiveClients(_ownerId);
      state = _reordered(
        state.copyWith(
          status: clients.isEmpty
              ? BaseStateStatus.noData
              : BaseStateStatus.success,
          clients: clients,
          rateBook: await _loadRateBook(),
        ),
      );
      await _loadTotalCount();
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Today's rates, for the lifetime figures. Fail-open: an empty book still
  /// renders, with the amounts flagged incomplete.
  Future<RateBook> _loadRateBook() async {
    try {
      final history = await ref.read(exchangeRateHistoryServiceProvider.future);
      return await history.bookFor([_todayKey]);
    } catch (_) {
      return const RateBook.empty();
    }
  }

  String get _todayKey => ExchangeRates.dateKeyOf(DateTime.now());

  void onChangeOrder(ClientOrder order) {
    if (order == state.order) return;
    state = _reordered(state.copyWith(order: order));
  }

  /// Sorts the loaded clients by [ClientsState.order].
  ///
  /// A client with no service goes last under "último serviço" whatever their
  /// stored date says — `lastServiceDate` defaults to a sentinel year, and
  /// sorting on it would scatter them through the list.
  ClientsState _reordered(ClientsState from) {
    double earnings(ClientEntry client) => client.counters
        .commissionIn(
          from.defaultCurrency,
          rateBook: from.rateBook,
          legacyCurrency: from.defaultCurrency,
          dateKey: _todayKey,
        )
        .amount;

    int byName(ClientEntry a, ClientEntry b) =>
        a.info.user.name.toLowerCase().compareTo(b.info.user.name.toLowerCase());

    final sorted = [...from.clients];

    switch (from.order) {
      case ClientOrder.alphabetical:
        sorted.sort(byName);
      case ClientOrder.topEarning:
        sorted.sort((a, b) {
          final compared = earnings(b).compareTo(earnings(a));
          return compared != 0 ? compared : byName(a, b);
        });
      case ClientOrder.lastService:
        sorted.sort((a, b) {
          final aServed = a.counters.count > 0;
          final bServed = b.counters.count > 0;
          if (aServed != bServed) return aServed ? -1 : 1;
          if (!aServed) return byName(a, b);
          return b.info.lastServiceDate.compareTo(a.info.lastServiceDate);
        });
    }

    return from.copyWith(clients: sorted);
  }

  Future<void> onRefresh() => onInit();

  /// The header count covers every active client, and the archive entry every
  /// archived one, so neither can be derived from the loaded page. A failure
  /// here leaves them unset rather than taking the listing down with it.
  Future<void> _loadTotalCount() async {
    try {
      final total = await _clientsRepository.countActive(_ownerId);
      final archived = await _clientsRepository.countArchived(_ownerId);
      state = state.copyWith(totalCount: total, archivedCount: archived);
    } catch (_) {
      // Already logged by the repository.
    }
  }

  void onOpenSearch() {
    if (state.isSearching) return;
    state = state.copyWith(isSearching: true, query: '');
  }

  Future<void> onCloseSearch() async {
    if (!state.isSearching) return;
    await onInit();
  }

  Future<void> onSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      // Back to the full list, but still in search mode: clearing the field is
      // not the same as closing it.
      await onInit();
      state = state.copyWith(isSearching: true);
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
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Hides a client from the listing without touching a thing its services
  /// read. Reversible with [restoreClient]. See core/archiving.md.
  Future<bool> archiveClient(String clientId) async {
    try {
      await _clientsRepository.archive(clientId);
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
        archivedCount: state.archivedCount + 1,
      );
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              AnalyticsEvent.recordArchived,
              parameters: const {'entity': 'client'},
            ),
      );
      return true;
    } on AppError catch (exception) {
      onAppError(exception);
      return false;
    } catch (exception) {
      unexpectedError(exception);
      return false;
    }
  }

  Future<void> restoreClient(ClientEntry entry, {String? source}) async {
    try {
      await _clientsRepository.restore(entry.id);
      appendClient((id: entry.id, info: entry.info, archivedAt: null, counters: const RecordCounters(), observation: entry.observation, createdAt: entry.createdAt));
      state = state.copyWith(
        archivedCount: (state.archivedCount - 1).clamp(0, state.archivedCount),
      );
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              AnalyticsEvent.recordRestored,
              parameters: {
                'entity': 'client',
                if (source != null) 'source': source,
              },
            ),
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _clientsRepository.delete(clientId);
      state = state.copyWith(
        archivedCount: (state.archivedCount - 1).clamp(0, state.archivedCount),
      );
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              AnalyticsEvent.recordDeleted,
              parameters: const {'entity': 'client'},
            ),
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

    state = _reordered(
      state.copyWith(
        status: BaseStateStatus.success,
        clients: [...state.clients, entry],
        totalCount: counted,
      ),
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
