import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/kazi_emphasized_text.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A short sentence the screen has to say before the person acts, laid on the
/// brand wash inside the flow rather than thrown over it as a dialog.
///
/// For what a screen has *noticed* and wants confirmed — a namesake, a rate it
/// could not resolve. What must be decided before anything else happens is a
/// dialog; what merely changes the meaning of the next tap is this.
class KaziNote extends StatelessWidget {
  const KaziNote(this.text, {super.key}) : emphasis = null;

  /// Bolds [emphasis] inside [text] — the name the note is about, which is
  /// what the person scans for before reading the sentence.
  const KaziNote.emphasizing(this.text, {super.key, required this.emphasis});

  final String text;
  final String? emphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = KaziTextStyles.labelSmall.copyWith(
      color: colors.brand.onSurface,
    );

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
      child: emphasis == null
          ? Text(text, style: style)
          : KaziEmphasizedText(text, emphasis: emphasis!, style: style),
    );
  }
}
