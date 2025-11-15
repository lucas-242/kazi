import 'package:flutter/material.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
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
    return PillButton(
      onTap: onTap,
      backgroundColor: isSelected ? KaziColors.black : KaziColors.grey,
      child: Text(text),
    );
  }
}
