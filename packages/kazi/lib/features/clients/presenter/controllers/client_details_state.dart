import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';

class ClientDetailsState extends BaseState {
  ClientDetailsState({
    required super.status,
    super.callbackMessage,
    this.client,
  });

  final ClientEntry? client;

  @override
  ClientDetailsState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    ClientEntry? client,
  }) {
    return ClientDetailsState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      client: client ?? this.client,
    );
  }
}
