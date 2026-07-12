import 'package:kazi_core/kazi_core.dart';

class ClientsState {
  const ClientsState({
    this.clients = const [],
    this.currentPage = 1,
    this.itemsPerPage = 2,
  });

  final List<ClientInfo> clients;
  final int currentPage;
  final int itemsPerPage;

  int get totalPages =>
      (clients.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();

  List<ClientInfo> get currentPageClients {
    final start = (currentPage - 1) * itemsPerPage;

    if (start >= clients.length) {
      return [];
    }

    final end = (start + itemsPerPage).clamp(0, clients.length);

    return clients.sublist(start, end);
  }

  ClientsState copyWith({
    List<ClientInfo>? clients,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}
