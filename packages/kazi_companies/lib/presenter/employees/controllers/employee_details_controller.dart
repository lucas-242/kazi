import 'package:kazi_core/kazi_core.dart';

part 'employee_details_controller.g.dart';

@riverpod
class EmployeeDetailsController extends _$EmployeeDetailsController {
  UserRepository get repository => ref.read(usersRepositoryProvider);

  @override
  FutureOr<EmployeeDetailsInitialState> build({
    User? employee,
    int? employeeId,
  }) async {
    if (employee != null) {
      return EmployeeDetailsInitialState(employee: employee);
    }

    if (employeeId == null) {
      throw UsersError(UsersFailure.notFound);
    }

    final response = await repository.getById(employeeId);
    return EmployeeDetailsInitialState(employee: response);
  }
}

final class EmployeeDetailsInitialState {
  const EmployeeDetailsInitialState({required this.employee});

  final User? employee;
}
