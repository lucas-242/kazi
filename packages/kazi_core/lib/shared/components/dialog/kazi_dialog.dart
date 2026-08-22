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
    this.isDestructive = false,
  });
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String title;
  final String message;
  final String? cancelText;
  final String? confirmText;

  /// Tighter than the Material default: at half the dialog's width, the
  /// default 24 leaves a two-word label wrapping onto four lines.
  static const _labelPadding = EdgeInsets.symmetric(horizontal: KaziInsets.sm);

  /// The confirmation is the answer that costs something — signing out,
  /// deleting. It moves to the left in outline and the dismissal takes the
  /// filled slot on the right, so the safe answer is the one under the thumb.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final confirmLabel = confirmText ?? KaziLocalizations.current.continueAction;
    final cancelLabel = cancelText ?? KaziLocalizations.current.cancel;

    final (String leftLabel, VoidCallback leftTap) = isDestructive
        ? (confirmLabel, onConfirm)
        : (cancelLabel, onCancel);
    final (String rightLabel, VoidCallback rightTap) = isDestructive
        ? (cancelLabel, onCancel)
        : (confirmLabel, onConfirm);

    return AlertDialog(
      key: key ?? const Key('KaziDialog'),
      title: Text(title, style: KaziTextStyles.titleMedium),
      content: Text(message, style: KaziTextStyles.bodyMedium),
      // Surface and shape come from `dialogTheme`.
      actions: [
        // A row of halves rather than the `OverflowBar` the actions default
        // to, which stacks the buttons as soon as two labels do not fit side
        // by side. `IntrinsicHeight` keeps both the same size when one wraps.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: KaziElevatedButton.outlined(
                  onTap: leftTap,
                  label: leftLabel,
                  labelStyle: KaziTextStyles.titleSmall,
                  padding: _labelPadding,
                ),
              ),
              KaziSpacings.horizontalXs,
              Expanded(
                child: KaziElevatedButton.label(
                  onTap: rightTap,
                  label: rightLabel,
                  labelStyle: KaziTextStyles.titleSmall,
                  backgroundColor: colors.inverse,
                  foregroundColor: colors.onInverse,
                  padding: _labelPadding,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
