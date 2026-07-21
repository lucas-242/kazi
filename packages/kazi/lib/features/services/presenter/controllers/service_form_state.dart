import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ServiceFormState extends BaseState with Equatable {
  ServiceFormState({
    required super.status,
    Service? service,
    required this.userId,
    super.callbackMessage,
    List<ServiceType>? serviceTypes,
    List<ClientEntry>? clients,
    int? quantity,
  }) : service = service ?? Service(userId: userId),
       serviceTypes = serviceTypes ?? const [],
       clients = clients ?? const [],
       quantity = quantity ?? 1;

  final Service service;
  final List<ServiceType> serviceTypes;
  final List<ClientEntry> clients;
  final int quantity;
  final String userId;

  List<DropdownItem> get dropdownItems {
    final result =
        serviceTypes
            .map((e) => DropdownItem(value: e.id, label: e.name))
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return result;
  }

  DropdownItem? get selectedDropdownItem {
    if (service.typeId.isEmpty) return null;

    final result = dropdownItems.where((x) => x.value == service.typeId);

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
    List<ServiceType>? serviceTypes,
    List<ClientEntry>? clients,
    int? quantity,
  }) {
    return ServiceFormState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      service: service ?? this.service,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      clients: clients ?? this.clients,
      quantity: quantity ?? this.quantity,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
    service,
    serviceTypes,
    clients,
    quantity,
    userId,
    status,
    callbackMessage,
  ];
}
