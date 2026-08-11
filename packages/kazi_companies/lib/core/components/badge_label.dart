import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class BadgeLabel extends StatelessWidget {
  const BadgeLabel({
    super.key,
    required this.text,
    this.icon,
    required this.color,
  });
  final String text;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziInsets.xs,
        vertical: KaziInsets.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(KaziInsets.xxs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: KaziInsets.md,
              color: color,
            ),
            const SizedBox(width: KaziInsets.xxs),
          ],
          Text(
            text,
            style: KaziTextStyles.titleSmall.copyWith(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
