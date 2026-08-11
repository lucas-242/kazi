import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class KaziDialog extends StatelessWidget {
  const KaziDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.title,
    required this.message,
    this.cancelText,
    this.confirmText,
  });
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String title;
  final String message;
  final String? cancelText;
  final String? confirmText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key ?? const Key('KaziDialog'),
      title: Text(title, style: KaziTextStyles.titleMedium),
      content: Text(message, style: KaziTextStyles.bodyMedium),
      // Surface and shape come from `dialogTheme`.
      actions: [
        KaziPillButton(
          onTap: onCancel,
          child: Text(cancelText ?? KaziLocalizations.current.cancel),
        ),
        KaziPillButton(
          onTap: onConfirm,
          backgroundColor: context.colors.danger.fill,
          child: Text(confirmText ?? KaziLocalizations.current.continueAction),
        ),
      ],
    );
  }
}
