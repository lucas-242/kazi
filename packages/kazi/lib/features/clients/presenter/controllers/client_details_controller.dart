import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'client_details_state.dart';

part 'client_details_controller.g.dart';

@riverpod
class ClientDetailsController extends _$ClientDetailsController
    with BaseNotifier<ClientDetailsState> {
  ClientsRepository get _clientsRepository => ref.read(clientsRepositoryProvider);

  @override
  ClientDetailsState build({required String clientId}) {
    _load(clientId);
    return ClientDetailsState(status: BaseStateStatus.loading);
  }

  Future<void> _load(String clientId) async {
    try {
      final client = await _clientsRepository.getClientDetails(clientId);
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
