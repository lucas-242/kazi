import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A round icon button with its label underneath — the dashboard's
/// "New service / Add client / Catalog" row, and any other place that wants
/// a few big, equally-weighted actions side by side.
///
/// Brand yellow by default, for the one action that outranks the others.
/// Pass [isPrimary] false for a secondary action, which gets a quiet
/// bordered disc instead — the row can carry only one yellow.
class KaziQuickActionButton extends StatelessWidget {
  const KaziQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;

  static const double _diameter = 52;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = isPrimary ? colors.brand.fill : colors.card;
    final foreground = isPrimary ? colors.brand.onFill : colors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _diameter,
          height: _diameter,
          child: Material(
            color: background,
            shape: CircleBorder(
              side: isPrimary
                  ? BorderSide.none
                  : BorderSide(color: colors.border),
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Icon(icon, color: foreground),
            ),
          ),
        ),
        KaziSpacings.verticalXxs,
        Text(
          label,
          style: KaziTextStyles.labelMedium.copyWith(color: colors.text),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
