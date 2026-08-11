import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class PersonalInfoRow extends StatelessWidget {
  const PersonalInfoRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
  });
  final String label;
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: KaziInsets.sm,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KaziInsets.xs),
            color: color.withAlpha(100),
          ),
          padding: const EdgeInsets.all(KaziInsets.sm),
          child: Icon(icon, color: color),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: KaziTextStyles.labelLarge),
            Text(text, style: KaziTextStyles.titleSmall),
          ],
        ),
      ],
    );
  }
}
