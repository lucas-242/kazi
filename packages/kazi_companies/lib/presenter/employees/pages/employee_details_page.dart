import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/personal_info_card/personal_info_card.dart';
import 'package:kazi_companies/core/components/services_badge_list.dart';
import 'package:kazi_companies/presenter/employees/controllers/employee_details_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class EmployeeDetailsPage extends ConsumerWidget {
  const EmployeeDetailsPage({
    super.key,
    this.id,
    this.employee,
  });
  final int? id;
  final User? employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeDetailsAsync = ref.watch(
      employeeDetailsControllerProvider(employee: employee, employeeId: id),
    );

    return KaziSafeArea(
      child: employeeDetailsAsync.when(
        loading: () => const KaziLoading(),
        error: (error, stack) => Center(
          child: Text('Erro: $error'),
        ),
        data: (state) => switch (state) {
          EmployeeDetailsInitialState() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonalInfoCard(user: state.employee!),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(KaziInsets.xLg),
                    child: Column(
                      spacing: KaziInsets.md,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Especialidades',
                          style: KaziTextStyles.headlineSm,
                        ),
                        ServicesBadgeList(user: state.employee!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }
}
