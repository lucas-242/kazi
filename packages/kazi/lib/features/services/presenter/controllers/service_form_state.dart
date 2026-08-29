import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ServiceFormState extends BaseState with Equatable {
  ServiceFormState({
    required super.status,
    Service? service,
    required this.userId,
    super.callbackMessage,
    List<CatalogItem>? catalogItems,
    List<ClientEntry>? clients,
    List<ClientEntry>? archivedClients,
    int? quantity,
  }) : service = service ?? Service(userId: userId),
       catalogItems = catalogItems ?? const [],
       clients = clients ?? const [],
       archivedClients = archivedClients ?? const [],
       quantity = quantity ?? 1;

  final Service service;

  /// Every catalog item the user owns, archived ones included: the picker only
  /// offers the active ones, but a service already registered against an item
  /// archived since must still show its name.
  final List<CatalogItem> catalogItems;
  final List<ClientEntry> clients;
  /// Kept for [selectedClientDropdownItem]: they are never offered as options.
  final List<ClientEntry> archivedClients;
  final int quantity;
  final String userId;

  List<DropdownItem> get dropdownItems =>
      activeCatalogItems.map(_catalogDropdownItem).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

  DropdownItem _catalogDropdownItem(CatalogItem item) =>
      DropdownItem(value: item.id, label: item.name, color: item.colorAs);

  /// Catalog items offered as ordinary options, the archived ones excluded —
  /// what a freshly opened form should count as available.
  List<CatalogItem> get activeCatalogItems =>
      catalogItems.where((item) => !item.isArchived).toList();

  /// Resolved against every item rather than the offered ones, so editing a
  /// service whose item was archived still shows what it was registered under.
  DropdownItem? get selectedDropdownItem {
    if (service.catalogItemId.isEmpty) return null;

    for (final item in catalogItems) {
      if (item.id == service.catalogItemId) return _catalogDropdownItem(item);
    }
    return null;
  }

  List<DropdownItem> get clientDropdownItems =>
      clients.map(_clientDropdownItem).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

  DropdownItem _clientDropdownItem(ClientEntry entry) =>
      DropdownItem(value: entry.id, label: entry.info.user.name);

  /// Resolved against the archived clients too, for the same reason
  /// [selectedDropdownItem] is.
  ///
  /// Falls back to the service's own `clientName` when the id resolves to
  /// nothing — the client was deleted, and an edit must not read as if the
  /// service had lost them. The item is deliberately absent from
  /// [clientDropdownItems]: it shows as selected but is never offered, because
  /// there is nothing left to pick.
  DropdownItem? get selectedClientDropdownItem {
    final clientId = service.clientId;
    if (clientId == null || clientId.isEmpty) return null;

    for (final entry in [...clients, ...archivedClients]) {
      if (entry.id == clientId) return _clientDropdownItem(entry);
    }

    final name = service.clientName;
    if (name == null || name.isEmpty) return null;
    return DropdownItem(value: clientId, label: name);
  }

  @override
  ServiceFormState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    Service? service,
    List<CatalogItem>? catalogItems,
    List<ClientEntry>? clients,
    List<ClientEntry>? archivedClients,
    int? quantity,
  }) {
    return ServiceFormState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      service: service ?? this.service,
      catalogItems: catalogItems ?? this.catalogItems,
      clients: clients ?? this.clients,
      archivedClients: archivedClients ?? this.archivedClients,
      quantity: quantity ?? this.quantity,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
    service,
    catalogItems,
    clients,
    archivedClients,
    quantity,
    userId,
    status,
    callbackMessage,
  ];
}
