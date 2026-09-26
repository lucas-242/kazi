import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The small upper-cased name of a field, or of a group of controls that is
/// not a field — the date chips, the colour row. It is the one caption in the
/// app, so a group and a box never label themselves differently.
class KaziFieldCaption extends StatelessWidget {
  const KaziFieldCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
    );
  }
}
