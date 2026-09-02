import 'package:flutter/material.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi_core/kazi_core.dart';

/// Archives [client] and offers the move back, from wherever the user did it.
///
/// Returns whether the client was archived, so a details screen can decide to
/// close itself. `KaziSnackbar` carries no action, so this uses Material's own
/// — the same path the bulk receipt action takes.
Future<bool> archiveClientWithUndo(
  BuildContext context,
  WidgetRef ref,
  ClientEntry client,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final controller = ref.read(clientsControllerProvider.notifier);

  final archived = await controller.archiveClient(client.id);
  if (!archived) return false;

  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 7),
      persist: false,
      content: Text(
        KaziLocalizations.current.archivedSnackbar(client.info.user.name),
      ),
      action: SnackBarAction(
        label: KaziLocalizations.current.undo,
        onPressed: () => controller.restoreClient(client),
      ),
    ),
  );

  return true;
}
