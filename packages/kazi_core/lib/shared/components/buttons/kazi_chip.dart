import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A selectable filter chip: outlined when off, inverted when on.
///
/// Selection is carried by ink and weight rather than by colour — the brand
/// yellow belongs to the FAB, and a yellow chip in a row of chips would make
/// the filter compete with the action that registers a service.
class KaziChip extends StatelessWidget {
  const KaziChip({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.onClear,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  /// Shows a trailing dismiss affordance. For chips that hold a value the user
  /// picked — clearing it is a different action from opening the picker again.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = isSelected ? colors.onInverse : colors.text;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? colors.inverse : colors.card,
        borderRadius: KaziRadii.fullBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: KaziRadii.fullBorder,
          child: Container(
            // A square minimum, not just a minimum height: short content (a
            // single digit, an icon-only chip) then reads as a circle rather
            // than an oval, and only stretches into a pill once the label
            // itself needs more room than that.
            constraints: const BoxConstraints(
              minHeight: KaziSizings.chipHeight,
              minWidth: KaziSizings.chipHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: KaziInsets.sm,
              vertical: KaziInsets.xxs,
            ),
            decoration: BoxDecoration(
              borderRadius: KaziRadii.fullBorder,
              border: Border.all(
                color: isSelected ? colors.inverse : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: KaziTextStyles.labelSmall.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (onClear != null) ...[
                  KaziSpacings.horizontalXxs,
                  // Its own tap target inside the chip: tapping the label
                  // reopens the picker, tapping the cross drops the filter.
                  InkResponse(
                    onTap: onClear,
                    radius: KaziSizings.iconSm,
                    child: Icon(
                      Icons.close,
                      size: KaziSizings.iconSm,
                      color: foreground,
                    ),
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
