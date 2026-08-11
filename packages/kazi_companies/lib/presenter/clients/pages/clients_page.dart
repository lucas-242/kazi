import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/user_card/user_card.dart';
import 'package:kazi_companies/core/routes/extensions/routes_extensions.dart';
import 'package:kazi_companies/presenter/clients/controllers/clients_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientsControllerProvider.notifier);
    final state = ref.watch(clientsControllerProvider);

    return state.when(
      loading: () => const KaziLoading(),
      error: (error, stackTrace) => KaziError(message: error.toString()),
      data: (state) {
        final currentPageClients = state.currentPageClients;
        final currentPage = state.currentPage;
        final totalPages = state.totalPages;

        return KaziSafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaziPageTitle(
                title: 'Clientes',
                searchLabel: 'Buscar Clientes...',
                onFilter: () {},
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: KaziInsets.md,
                    mainAxisSpacing: KaziInsets.md,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: state.currentPageClients.length,
                  itemBuilder: (context, index) {
                    final client = currentPageClients[index];
                    return UserCard(
                      user: client.user,
                      clientInfo: client,
                      onEdit: (user) {},
                      onDelete: (user) {
                        context.openDialog(
                          child: KaziDialog(
                            onConfirm: () {
                              controller.delete(user);
                              context.closeDialog();
                            },
                            onCancel: context.closeDialog,
                            title: 'Deletar',
                            message:
                                'Você está prestes a deletar o cliente ${user.name}',
                          ),
                        );
                      },
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
