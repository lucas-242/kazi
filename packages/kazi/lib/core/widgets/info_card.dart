import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.width,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(KaziInsets.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: KaziTextStyles.titleMd.copyWith(
                    color: context.colorsScheme.surface,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                Text(
                  subtitle,
                  style: KaziTextStyles.titleSm.copyWith(
                    color: context.colorsScheme.surface,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            KaziSvg(icon, height: 35, color: context.colorsScheme.surface),
          ],
        ),
      ),
    );
  }
}
