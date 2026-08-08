import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class KaziFieldLabel extends StatelessWidget {
  const KaziFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: KaziTextStyles.sm.copyWith(
            color: context.colorsScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
