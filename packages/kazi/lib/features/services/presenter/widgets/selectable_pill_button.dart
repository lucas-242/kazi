import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class SelectablePillButton extends StatelessWidget {
  const SelectablePillButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.isSelected,
  });
  final VoidCallback onTap;
  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return KaziPillButton(
      onTap: onTap,
      backgroundColor: isSelected
          ? context.colorsScheme.inverseSurface
          : context.colorsScheme.onSurfaceVariant,
      child: Text(text),
    );
  }
}
