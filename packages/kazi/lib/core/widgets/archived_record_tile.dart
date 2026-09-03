import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// One row of an archive screen, for a client or a catalog item alike.
///
/// Carries no rule about who may be deleted: the two archives answer that
/// differently, so each screen decides [deletable], the [note] under the date
/// and the [deleteMessage]. See core/archiving.md.
class ArchivedRecordTile extends StatelessWidget {
  const ArchivedRecordTile({
    super.key,
    required this.name,
    required this.archivedAt,
    required this.note,
    required this.deletable,
    required this.deleteMessage,
    required this.onRestore,
    required this.onDelete,
    this.onBlockedDelete,
  });

  final String name;
  final DateTime? archivedAt;

  /// A line under the archive date, typically the linked-service count.
  final String? note;

  final bool deletable;
  final String deleteMessage;
  final VoidCallback onRestore;
  final Future<void> Function() onDelete;

  /// What a tap does when the record may not be deleted. Given one, the button
  /// stays on screen and explains itself — a missing button leaves the person
  /// wondering where it went, where a refusal with a number closes the
  /// question.
  final VoidCallback? onBlockedDelete;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => KaziDialog(
        title: KaziLocalizations.current.deleteForeverTitle(name),
        message: deleteMessage,
        confirmText: KaziLocalizations.current.deletePermanently,
        isDestructive: true,
        onCancel: KaziNavigator.pop,
        onConfirm: () async {
          KaziNavigator.pop();
          await onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(name, style: KaziTextStyles.titleSmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (archivedAt != null)
            Text(
              KaziLocalizations.current.archivedOn(archivedAt!.format()),
              style: KaziTextStyles.bodySmall.copyWith(color: colors.textMuted),
            ),
          if (note != null)
            Text(
              note!,
              style: KaziTextStyles.bodySmall.copyWith(color: colors.textMuted),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KaziCircularButton.plain(
            semantics: KaziLocalizations.current.restore,
            onTap: onRestore,
            child: Icon(
              Icons.unarchive_outlined,
              size: 18,
              color: colors.brand.text,
            ),
          ),
          if (!deletable && onBlockedDelete != null)
            KaziCircularButton.plain(
              semantics: KaziLocalizations.current.delete,
              onTap: onBlockedDelete,
              foregroundColor: colors.textMuted,
              child: const Icon(Icons.delete_outline, size: 18),
            ),
          if (deletable)
            KaziCircularButton.plain(
              semantics: KaziLocalizations.current.delete,
              onTap: () => _confirmDelete(context),
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: colors.danger.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}
