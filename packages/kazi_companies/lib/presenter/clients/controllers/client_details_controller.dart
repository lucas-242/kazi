import 'package:kazi_core/kazi_core.dart';

part 'client_details_controller.g.dart';

@riverpod
class ClientDetailsController extends _$ClientDetailsController {
  @override
  FutureOr<ClientInfo> build(
    String? clientId,
    ClientInfo? clientInfo,
  ) async {
    if (clientInfo == null && clientId == null) {
      throw UsersError(UsersFailure.notFound);
    }

    if (clientInfo != null) {
      return clientInfo;
    }

    final id = int.tryParse(clientId!);
    if (id == null) {
      throw UsersError(UsersFailure.notFound);
    }

    final user = await usersRepository(ref).getClientInfoById(id);
    if (user == null) {
      throw UsersError(UsersFailure.notFound);
    }

    return user;
  }
}
