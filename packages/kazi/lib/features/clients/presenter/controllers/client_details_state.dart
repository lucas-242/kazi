import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientDetailsState extends BaseState {
  ClientDetailsState({
    required super.status,
    super.callbackMessage,
    this.client,
    this.serviceHistory = const [],
    this.hasReachedMaxServices = false,
    this.isLoadingMoreServices = false,
  });

  final ClientEntry? client;

  final List<ServiceHistoryItem> serviceHistory;
  final bool hasReachedMaxServices;
  final bool isLoadingMoreServices;

  @override
  ClientDetailsState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    ClientEntry? client,
    List<ServiceHistoryItem>? serviceHistory,
    bool? hasReachedMaxServices,
    bool? isLoadingMoreServices,
  }) {
    return ClientDetailsState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      client: client ?? this.client,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      hasReachedMaxServices:
          hasReachedMaxServices ?? this.hasReachedMaxServices,
      isLoadingMoreServices:
          isLoadingMoreServices ?? this.isLoadingMoreServices,
    );
  }
}
