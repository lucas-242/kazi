import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onColor,
    this.width,
  });

  final String title;
  final String subtitle;
  final String icon;

  /// The card fill — a status role, never the brand yellow.
  final Color color;

  /// The ink that reads on [color]. Comes in as a pair with it so the card
  /// stays legible in both brightnesses; it used to be `surface`, which
  /// inverted to dark-on-saturated in dark mode.
  final Color onColor;

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
                    color: onColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                Text(
                  subtitle,
                  style: KaziTextStyles.titleSm.copyWith(
                    color: onColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            KaziSvg(icon, height: 35, color: onColor),
          ],
        ),
      ),
    );
  }
}
