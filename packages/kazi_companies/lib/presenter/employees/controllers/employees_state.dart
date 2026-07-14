import 'package:kazi_core/kazi_core.dart';

class EmployeesState {
  const EmployeesState({
    this.employees = const [],
    this.currentPage = 1,
    this.itemsPerPage = 12,
  });

  final List<User> employees;
  final int currentPage;
  final int itemsPerPage;

  int get totalPages => (employees.length / itemsPerPage)
      .ceil()
      .clamp(1, double.infinity)
      .toInt();

  List<User> get currentPageEmployees {
    final start = (currentPage - 1) * itemsPerPage;

    if (start >= employees.length) {
      return [];
    }

    final end = (start + itemsPerPage).clamp(0, employees.length);

    return employees.sublist(start, end);
  }

  EmployeesState copyWith({
    List<User>? employees,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}
