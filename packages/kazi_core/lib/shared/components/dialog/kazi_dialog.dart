import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// The app's confirmation dialog: a question, the answer that acts on it, and
/// the way out under it.
///
/// The two answers are **stacked, never side by side**. A row of halves makes
/// the two answers look interchangeable and puts the costly one a thumb-width
/// from the safe one; stacking gives the action the full width and demotes the
/// dismissal to plain text, which is the shape every dialog in `screens.html`
/// carries.
class KaziDialog extends StatelessWidget {
  const KaziDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.title,
    required this.message,
    this.cancelText,
    this.confirmText,
    this.isDestructive = false,
  });
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String title;
  final String message;
  final String? cancelText;
  final String? confirmText;

  /// Whether the confirmation destroys something — signing out, deleting.
  ///
  /// It does not move the buttons: it takes the fill away from the action and
  /// leaves it outlined in [KaziStatusColors.onSurface], so the answer that
  /// costs something never arrives as the loudest thing on screen.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final confirmLabel = confirmText ?? KaziLocalizations.current.continueAction;
    final cancelLabel = cancelText ?? KaziLocalizations.current.cancel;

    return AlertDialog(
      key: key ?? const Key('KaziDialog'),
      title: Text(title, style: KaziTextStyles.titleMedium),
      content: Text(message, style: KaziTextStyles.bodyMedium),
      // Surface and shape come from `dialogTheme`.
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDestructive)
              KaziElevatedButton.outlined(
                onTap: onConfirm,
                label: confirmLabel,
                labelStyle: KaziTextStyles.titleSmall,
                foregroundColor: colors.danger.onSurface,
              )
            else
              KaziElevatedButton.label(
                onTap: onConfirm,
                label: confirmLabel,
                labelStyle: KaziTextStyles.titleSmall,
                backgroundColor: colors.inverse,
                foregroundColor: colors.onInverse,
              ),
            KaziTextButton(
              onTap: onCancel,
              color: colors.textMuted,
              child: Text(cancelLabel),
            ),
          ],
        ),
      ],
    );
  }
}
