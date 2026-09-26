import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/user_card/user_card.dart';
import 'package:kazi_companies/presenter/employees/controllers/employees_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class EmployeesPage extends ConsumerWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(employeesControllerProvider.notifier);
    final state = ref.watch(employeesControllerProvider);

    return state.when(
      loading: () => const KaziLoading(),
      error: (error, stackTrace) => KaziError(message: error.toString()),
      data: (state) {
        final currentPageEmployees = state.currentPageEmployees;
        final currentPage = state.currentPage;
        final totalPages = state.totalPages;

        return KaziSafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaziPageTitle(
                title: KaziLocalizations.current.employees,
                searchLabel: 'Buscar Funcionários...',
                onFilter: () {},
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: context.width / 3,
                    crossAxisSpacing: KaziInsets.md,
                    mainAxisSpacing: KaziInsets.md,
                  ),
                  itemCount: state.currentPageEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = currentPageEmployees[index];
                    return UserCard(
                      user: employee,
                      onEdit: (user) {},
                      onDelete: (user) {},
                    );
                  },
                ),
              ),
              _PaginationControls(
                currentPage: currentPage,
                totalPages: totalPages,
                onPrevious: controller.previousPage,
                onNext: controller.nextPage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KaziInsets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          KaziElevatedButton.icon(
            onTap: currentPage > 1 ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
            label: 'Anterior',
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: KaziTextStyles.bodyMedium,
          ),
          KaziElevatedButton.icon(
            onTap: currentPage < totalPages ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            label: 'Próxima',
          ),
        ],
      ),
    );
  }
}
