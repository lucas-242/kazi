import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The sentence under a field that says what the field is for, or what the
/// fields above it come to. Part of the control, not a footnote to it.
class KaziFieldHint extends StatelessWidget {
  const KaziFieldHint(this.text, {super.key}) : _isEmphasis = false;

  /// Amber and bold: the answer the fields above produced, which reads as
  /// their consequence rather than as another field.
  const KaziFieldHint.emphasis(this.text, {super.key}) : _isEmphasis = true;

  final String text;
  final bool _isEmphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(
        top: KaziInsets.xxs,
        left: KaziInsets.xxs,
        bottom: KaziInsets.xs,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: _isEmphasis
              ? KaziTextStyles.labelSmall.copyWith(
                  color: colors.brand.text,
                  fontWeight: FontWeight.w700,
                )
              : KaziTextStyles.labelSmall.copyWith(color: colors.textMuted),
        ),
      ),
    );
  }
}
