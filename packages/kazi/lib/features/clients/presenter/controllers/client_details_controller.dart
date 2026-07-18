import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'client_details_state.dart';

part 'client_details_controller.g.dart';

@riverpod
class ClientDetailsController extends _$ClientDetailsController
    with BaseNotifier<ClientDetailsState> {
  ClientsRepository get _clientsRepository => ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  String get _ownerId => _authService.user!.uid;

  @override
  ClientDetailsState build({required String clientId}) {
    _load(clientId);
    return ClientDetailsState(status: BaseStateStatus.loading);
  }

  /// Pushes an edited client into the details state so the screen shows the new
  /// data without refetching from the backend. The service history is preserved
  /// by the caller when rebuilding the entry.
  void setClient(ClientEntry entry) {
    state = state.copyWith(status: BaseStateStatus.success, client: entry);
  }

  Future<void> _load(String clientId) async {
    try {
      final client = await _clientsRepository.getClientDetails(
        _ownerId,
        clientId,
      );
      state = state.copyWith(
        status: client == null
            ? BaseStateStatus.noData
            : BaseStateStatus.success,
        client: client,
      );
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }
}
