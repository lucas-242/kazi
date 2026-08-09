import 'package:flutter/material.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// Optional colour field: the six brandbook category colours plus "no colour".
///
/// Deliberately a fixed palette rather than a free picker — the category hexes
/// are an identity set, chosen to stay legible on both brightnesses, and an
/// arbitrary hex would break that contract.
class KaziColorSwatchPicker extends StatelessWidget {
  const KaziColorSwatchPicker({
    super.key,
    this.selected,
    required this.onChanged,
    this.swatchSize = 36,
  });

  /// The currently chosen colour, or null for "no colour".
  final Color? selected;

  /// Emits the chosen colour, or null when the user picks "no colour".
  final ValueChanged<Color?> onChanged;

  final double swatchSize;

  @override
  Widget build(BuildContext context) {
    final List<Color> categories = context.kaziColors.categories;

    return Wrap(
      spacing: KaziInsets.sm,
      runSpacing: KaziInsets.sm,
      children: [
        for (var index = 0; index < categories.length; index++)
          _Swatch(
            color: context.kaziColors.category(index),
            isSelected: selected == context.kaziColors.category(index),
            size: swatchSize,
            onTap: () => onChanged(context.kaziColors.category(index)),
          ),
        _Swatch(
          color: null,
          isSelected: selected == null,
          size: swatchSize,
          label: KaziLocalizations.current.noColor,
          onTap: () => onChanged(null),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.size,
    required this.onTap,
    this.label,
  });

  final Color? color;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;
  final String? label;

  /// Ink that reads on top of [color]. The category colours are all mid-dark,
  /// but the luminance check keeps this honest if the palette ever lightens.
  Color _inkOn(BuildContext context, Color background) =>
      background.computeLuminance() > 0.5
      ? context.colorsScheme.onSurface
      : context.colorsScheme.surface;

  @override
  Widget build(BuildContext context) {
    final Color background =
        color ?? context.colorsScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? context.kaziColors.focusRing
                  : context.colorsScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: size / 2,
                    color: _inkOn(context, background),
                  )
                : color == null
                ? Icon(
                    Icons.block,
                    size: size / 2,
                    color: context.colorsScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
