import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/archived_record_tile.dart';
import 'package:kazi/features/clients/presenter/controllers/archived_clients_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class ArchivedClientsPage extends ConsumerStatefulWidget {
  const ArchivedClientsPage({super.key});

  @override
  ConsumerState<ArchivedClientsPage> createState() =>
      _ArchivedClientsPageState();
}

class _ArchivedClientsPageState extends ConsumerState<ArchivedClientsPage> {
  bool _leaving = false;

  /// Spells out what deletion takes and what it leaves, so nobody reads it as
  /// "this erases the work I did for them".
  String _deleteMessage(String name, int? services) {
    final confirm = KaziLocalizations.current.deleteClientConfirm(name);
    if (services == null || services == 0) return confirm;

    return '$confirm\n\n'
        '${KaziLocalizations.current.deleteClientKeepsServices(services)}';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(archivedClientsControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archivedClientsControllerProvider);
    final controller = ref.read(archivedClientsControllerProvider.notifier);

    // Emptying the screen leaves nothing to come back to: leave rather than
    // show an empty archive. Guarded, because build runs again before the
    // microtask lands and a second pop would take the caller's screen with it.
    if (state.clients.isEmpty &&
        state.status != BaseStateStatus.loading &&
        !_leaving) {
      _leaving = true;
      Future.microtask(KaziNavigator.pop);
    }

    return Scaffold(
      appBar: KaziAppBar(title: KaziLocalizations.current.archivedClients),
      body: KaziSafeArea(
        onRefresh: controller.onInit,
        child: switch (state.status) {
          BaseStateStatus.loading => const KaziSkeletonList(count: 3),
          BaseStateStatus.error => KaziError(
            message: state.callbackMessage,
            onRetry: controller.onInit,
          ),
          _ => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.clients.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final client = state.clients[index];
              final services = state.countFor(client.id);

              return ArchivedRecordTile(
                name: client.info.user.name,
                archivedAt: client.archivedAt,
                // The count informs; it does not gate. Someone asking to be
                // removed is usually someone already served, so a rule barring
                // deletion above zero services would close the door precisely
                // when it has to open. See core/archiving.md.
                deletable: true,
                note: services == null || services == 0
                    ? null
                    : KaziLocalizations.current.servicesCount(services),
                deleteMessage: _deleteMessage(client.info.user.name, services),
                onRestore: () => controller.restoreClient(client),
                onDelete: () => controller.deleteClient(client),
              );
            },
          ),
        },
      ),
    );
  }
}
