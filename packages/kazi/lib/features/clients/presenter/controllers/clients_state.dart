import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';

class ClientsState extends BaseState {
  ClientsState({
    required super.status,
    super.callbackMessage,
    List<ClientEntry>? clients,
    this.hasReachedMax = false,
    this.query = '',
    this.totalCount,
  }) : clients = clients ?? [];

  final List<ClientEntry> clients;
  final bool hasReachedMax;
  final String query;

  /// Every active client the user owns, not just the loaded page — and not
  /// narrowed by a search. `null` until the count comes back (or when it
  /// failed, which never blocks the listing).
  final int? totalCount;

  @override
  ClientsState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<ClientEntry>? clients,
    bool? hasReachedMax,
    String? query,
    int? totalCount,
  }) {
    return ClientsState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      clients: clients ?? this.clients,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
