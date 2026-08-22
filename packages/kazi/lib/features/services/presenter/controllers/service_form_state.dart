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
    int? quantity,
  }) : service = service ?? Service(userId: userId),
       catalogItems = catalogItems ?? const [],
       clients = clients ?? const [],
       quantity = quantity ?? 1;

  final Service service;
  final List<CatalogItem> catalogItems;
  final List<ClientEntry> clients;
  final int quantity;
  final String userId;

  List<DropdownItem> get dropdownItems {
    final result =
        catalogItems
            .map(
              (e) => DropdownItem(value: e.id, label: e.name, color: e.colorAs),
            )
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return result;
  }

  DropdownItem? get selectedDropdownItem {
    if (service.catalogItemId.isEmpty) return null;

    final result = dropdownItems.where((x) => x.value == service.catalogItemId);

    if (result.isEmpty) return null;

    return result.first;
  }

  List<DropdownItem> get clientDropdownItems {
    final result =
        clients
            .map((e) => DropdownItem(value: e.id, label: e.info.user.name))
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return result;
  }

  DropdownItem? get selectedClientDropdownItem {
    final clientId = service.clientId;
    if (clientId == null || clientId.isEmpty) return null;

    final result = clientDropdownItems.where((x) => x.value == clientId);

    if (result.isEmpty) return null;

    return result.first;
  }

  @override
  ServiceFormState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    Service? service,
    List<CatalogItem>? catalogItems,
    List<ClientEntry>? clients,
    int? quantity,
  }) {
    return ServiceFormState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      service: service ?? this.service,
      catalogItems: catalogItems ?? this.catalogItems,
      clients: clients ?? this.clients,
      quantity: quantity ?? this.quantity,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
    service,
    catalogItems,
    clients,
    quantity,
    userId,
    status,
    callbackMessage,
  ];
}
