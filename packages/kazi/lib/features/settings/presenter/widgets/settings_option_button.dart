import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// One row of the menu: an icon, a label, and — when the row is a setting
/// rather than a destination — the value currently in force.
///
/// Reporting the value on the row is the point of the layout. "Moeda ›" makes
/// you open the sheet to find out what the currency is; "Moeda · BRL · R$"
/// answers the question without a tap, and the sheet is only for changing it.
class SettingsOptionButton extends StatelessWidget {
  const SettingsOptionButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
    this.value,
    this.subValue,
    this.isDestructive = false,
    this.isHighlighted = false,
  });

  final VoidCallback onTap;
  final String text;
  final IconData icon;

  /// The setting's current value, shown muted at the end of the row. Null for
  /// rows that go somewhere rather than hold a value.
  final String? value;

  /// A second, more muted line under [value] — e.g. "Dia 5" under "Mensal".
  /// Ignored when [value] is null.
  final String? subValue;

  /// Sign out. Marked in red and isolated at the end of the list.
  final bool isDestructive;

  /// The one row allowed to carry the brand colour, as a soft wash. The menu
  /// has no FAB, so the screen's single yellow is free.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color background;
    final Color foreground;

    if (isHighlighted) {
      background = colors.brand.surface;
      foreground = colors.brand.onSurface;
    } else {
      background = colors.card;
      foreground = isDestructive ? colors.danger.onSurface : colors.text;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.xs),
      child: Material(
        color: background,
        borderRadius: KaziRadii.smBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: KaziRadii.smBorder,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: KaziSizings.minTouchTarget,
            ),
            decoration: BoxDecoration(
              borderRadius: KaziRadii.smBorder,
              border: Border.all(
                color: isHighlighted ? colors.brand.surface : colors.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: KaziInsets.md,
              vertical: KaziInsets.sm,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: KaziSizings.iconMd,
                  color: isDestructive || isHighlighted
                      ? foreground
                      : colors.textMuted,
                ),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: Text(
                    text,
                    style: KaziTextStyles.titleSmall.copyWith(
                      color: foreground,
                      fontWeight: isHighlighted ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                if (value != null) ...[
                  KaziSpacings.horizontalXs,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value!,
                        style: KaziTextStyles.labelSmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      if (subValue != null)
                        Text(
                          subValue!,
                          style: KaziTextStyles.labelSmall.copyWith(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
