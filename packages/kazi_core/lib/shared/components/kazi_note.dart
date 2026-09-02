import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A short sentence the screen has to say before the person acts, laid on the
/// brand wash inside the flow rather than thrown over it as a dialog.
///
/// For what a screen has *noticed* and wants confirmed — a namesake, a rate it
/// could not resolve. What must be decided before anything else happens is a
/// dialog; what merely changes the meaning of the next tap is this.
class KaziNote extends StatelessWidget {
  const KaziNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: KaziInsets.sm,
        vertical: KaziInsets.xs,
      ),
      decoration: BoxDecoration(
        color: colors.brand.surface,
        borderRadius: KaziRadii.mdBorder,
        border: Border.all(color: colors.brand.surfaceBorder),
      ),
      child: Text(
        text,
        style: KaziTextStyles.labelSmall.copyWith(
          color: colors.brand.onSurface,
        ),
      ),
    );
  }
}
