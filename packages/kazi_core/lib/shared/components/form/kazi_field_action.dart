import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// Action button inside a field, which creates the thing the picker could not
/// offer.
///
/// Outlined and on the page's own ground, so it reads as a control laid over
/// the field rather than as part of its value. A labelled pill and not a bare
/// plus — the icon alone left the person guessing what it would add, on a
/// screen with two of them.
class KaziFieldAction extends StatelessWidget {
  const KaziFieldAction({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      child: Material(
        color: colors.background,
        borderRadius: KaziRadii.fullBorder,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: KaziRadii.fullBorder,
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: KaziInsets.sm,
              vertical: KaziInsets.xs,
            ),
            child: Text(
              label,
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.brand.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
