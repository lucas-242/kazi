import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';

class ArchivedClientsState extends BaseState with Equatable {
  ArchivedClientsState({
    List<ClientEntry>? clients,
    Map<String, int>? serviceCounts,
    required super.status,
    super.callbackMessage,
  }) : clients = clients ?? const [],
       serviceCounts = serviceCounts ?? const {};

  final List<ClientEntry> clients;

  /// Services pointing at each archived client, keyed by client id. A missing
  /// key means the count has not loaded yet, which reads as "not deletable" —
  /// not knowing is not the same as knowing it is safe.
  final Map<String, int> serviceCounts;

  int? countFor(String id) => serviceCounts[id];

  @override
  ArchivedClientsState copyWith({
    List<ClientEntry>? clients,
    Map<String, int>? serviceCounts,
    BaseStateStatus? status,
    String? callbackMessage,
  }) {
    return ArchivedClientsState(
      clients: clients ?? this.clients,
      serviceCounts: serviceCounts ?? this.serviceCounts,
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
    );
  }

  @override
  List<Object?> get props => [
    clients,
    serviceCounts,
    status,
    callbackMessage,
  ];
}
