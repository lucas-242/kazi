import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/services/domain/models/service.dart';

class ClientDetailsState extends BaseState {
  ClientDetailsState({
    required super.status,
    super.callbackMessage,
    this.client,
    this.serviceHistory = const [],
    this.firstServiceDate,
    this.hasReachedMaxServices = false,
    this.isLoadingMoreServices = false,
  });

  final ClientEntry? client;

  final List<Service> serviceHistory;

  /// The oldest service performed for this client, or null when there is none.
  /// What "cliente desde" reads, ahead of the record's own creation date.
  final DateTime? firstServiceDate;
  final bool hasReachedMaxServices;
  final bool isLoadingMoreServices;

  @override
  ClientDetailsState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    ClientEntry? client,
    List<Service>? serviceHistory,
    DateTime? firstServiceDate,
    bool? hasReachedMaxServices,
    bool? isLoadingMoreServices,
  }) {
    return ClientDetailsState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      client: client ?? this.client,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      firstServiceDate: firstServiceDate ?? this.firstServiceDate,
      hasReachedMaxServices:
          hasReachedMaxServices ?? this.hasReachedMaxServices,
      isLoadingMoreServices:
          isLoadingMoreServices ?? this.isLoadingMoreServices,
    );
  }
}
