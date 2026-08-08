import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

enum _UserCardMenuOption { view, edit, delete }

class MoreOptionsPopup extends StatelessWidget {
  const MoreOptionsPopup({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UserCardMenuOption>(
      onSelected: (option) {
        switch (option) {
          case _UserCardMenuOption.view:
            return onView();
          case _UserCardMenuOption.edit:
            return onEdit();
          case _UserCardMenuOption.delete:
            return onDelete();
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KaziInsets.xs),
      ),
      color: context.colorsScheme.surfaceContainerHigh,
      style: IconButton.styleFrom(),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _UserCardMenuOption.view,
          child: Text('Visualizar'),
        ),
        const PopupMenuItem(
          value: _UserCardMenuOption.edit,
          child: Text('Editar'),
        ),
        const PopupMenuItem(
          value: _UserCardMenuOption.delete,
          child: Text('Deletar'),
        ),
      ],
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colorsScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KaziInsets.xs),
        ),
        child: const Center(
          child: Icon(Icons.more_horiz),
        ),
      ),
    );
  }
}
