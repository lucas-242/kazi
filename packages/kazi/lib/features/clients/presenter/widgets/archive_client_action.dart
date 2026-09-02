import 'package:flutter/material.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi_core/kazi_core.dart';

/// Archives [client] and offers the move back, from wherever the user did it.
///
/// Returns whether the client was archived, so a details screen can decide to
/// close itself.
Future<bool> archiveClientWithUndo(
  BuildContext context,
  WidgetRef ref,
  ClientEntry client,
) async {
  final controller = ref.read(clientsControllerProvider.notifier);

  final archived = await controller.archiveClient(client.id);
  if (!archived || !context.mounted) return archived;

  KaziUndoSnackbar.show(
    context,
    message: KaziLocalizations.current.archivedSnackbar(client.info.user.name),
    onUndo: () => controller.restoreClient(client),
  );

  return true;
}
