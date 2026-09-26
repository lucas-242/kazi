import 'package:kazi_companies/presenter/clients/controllers/clients_state.dart';
import 'package:kazi_core/kazi_core.dart';

part 'clients_controller.g.dart';

@riverpod
class ClientsController extends _$ClientsController {
  @override
  Future<ClientsState> build() async {
    final clients = await usersRepository(ref).getClientsInfo();
    return ClientsState(
      clients: clients,
    );
  }

  Future<void> delete(User user) async {
    await usersRepository(ref).delete(user.id);
  }

  void nextPage() {
    final current = state.requireValue;

    if (current.currentPage >= current.totalPages) return;

    state = AsyncData(
      current.copyWith(
        currentPage: current.currentPage + 1,
      ),
    );
  }

  void previousPage() {
    final current = state.requireValue;

    if (current.currentPage <= 1) return;

    state = AsyncData(
      current.copyWith(
        currentPage: current.currentPage - 1,
      ),
    );
  }
}
