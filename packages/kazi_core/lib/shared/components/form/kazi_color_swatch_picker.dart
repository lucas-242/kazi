import 'package:flutter/material.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// Optional colour field: the brandbook category colours plus "no colour".
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
    this.isScrollable = false,
  });

  /// The currently chosen colour, or null for "no colour".
  final Color? selected;

  /// Emits the chosen colour, or null when the user picks "no colour".
  final ValueChanged<Color?> onChanged;

  final double swatchSize;

  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final List<Color> categories = context.colors.categories;

    final swatches = <Widget>[
      for (var index = 0; index < categories.length; index++)
        _Swatch(
          color: context.colors.category(index),
          isSelected: selected == context.colors.category(index),
          size: swatchSize,
          onTap: () => onChanged(context.colors.category(index)),
        ),
      _Swatch(
        color: null,
        isSelected: selected == null,
        size: swatchSize,
        label: KaziLocalizations.current.noColor,
        onTap: () => onChanged(null),
      ),
    ];

    if (!isScrollable) {
      return Wrap(
        spacing: KaziInsets.sm,
        runSpacing: KaziInsets.sm,
        children: swatches,
      );
    }

    return SizedBox(
      height: swatchSize + KaziInsets.xs,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: swatches.length,
        separatorBuilder: (_, __) => KaziSpacings.horizontalSm,
        itemBuilder: (_, index) => Center(child: swatches[index]),
      ),
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

  @override
  Widget build(BuildContext context) {
    final Color background = color ?? context.colors.surfaceStrong;

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
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isSelected ? context.colors.focusRing : context.colors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: color == null
                  ? Icon(
                      Icons.block,
                      size: size / 2,
                      color: context.colors.textMuted,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
