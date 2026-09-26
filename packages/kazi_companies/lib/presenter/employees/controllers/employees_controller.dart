import 'package:kazi_companies/presenter/employees/controllers/employees_state.dart';
import 'package:kazi_core/kazi_core.dart';

part 'employees_controller.g.dart';

@riverpod
class EmployeesController extends _$EmployeesController {
  @override
  Future<EmployeesState> build() async {
    final employees =
        await repository.get(GetUsersParams(userType: UserType.employee));
    return EmployeesState(
      employees: employees,
    );
  }

  UserRepository get repository => ref.read(usersRepositoryProvider);

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
