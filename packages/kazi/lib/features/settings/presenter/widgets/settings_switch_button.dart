import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// A menu row that holds a boolean instead of going somewhere.
///
/// Shaped exactly like [SettingsOptionButton] — same card, same border, same
/// icon treatment — so the privacy group does not read as a different screen
/// bolted onto the menu. The difference is the second line: a consent switch
/// whose label is only two words is a switch nobody can make an informed
/// decision about, so [description] is required rather than optional.
class SettingsSwitchButton extends StatelessWidget {
  const SettingsSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
    required this.description,
    required this.icon,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.xs),
      child: Material(
        color: colors.card,
        borderRadius: KaziRadii.smBorder,
        child: InkWell(
          // The whole row toggles, not just the switch: it is a much larger
          // target than the thumb, and this row is one people are meant to be
          // able to find and change in a hurry.
          onTap: () => onChanged(!value),
          borderRadius: KaziRadii.smBorder,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: KaziSizings.minTouchTarget,
            ),
            decoration: BoxDecoration(
              borderRadius: KaziRadii.smBorder,
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: KaziInsets.md,
              vertical: KaziInsets.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Aligns the icon with the label rather than with the block,
                  // which the description would otherwise drag off-centre.
                  padding: const EdgeInsets.only(top: KaziInsets.xxs),
                  child: Icon(
                    icon,
                    size: KaziSizings.iconMd,
                    color: colors.textMuted,
                  ),
                ),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: KaziTextStyles.titleSmall.copyWith(
                          color: colors.text,
                        ),
                      ),
                      KaziSpacings.verticalXxs,
                      Text(
                        description,
                        style: KaziTextStyles.bodySmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                KaziSpacings.horizontalXs,
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: colors.brand.onFill,
                  activeTrackColor: colors.brand.fill,
                  inactiveThumbColor: colors.surfaceStrong,
                  inactiveTrackColor: colors.surfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
