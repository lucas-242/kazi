import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/settings/kazi_palette.dart';
import 'package:kazi_core/shared/themes/themes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A circular badge marking a service's category colour in a list row —
/// [KaziColorDot] scaled up with a generic mark inside, for rows that want a
/// leading avatar rather than an edge stripe ([KaziCategoryBorder]).
///
/// Catalog items carry only a colour, not an icon, so every badge shows the
/// same mark — the colour alone is what tells two categories apart.
class KaziCategoryAvatar extends StatelessWidget {
  const KaziCategoryAvatar({super.key, this.color, this.radius = 20});

  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final background = color ?? context.colors.surfaceStrong;
    final isLight =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: Icon(
        LucideIcons.receipt,
        size: radius,
        color: isLight ? KaziPalette.graphite : KaziPalette.mist,
      ),
    );
  }
}
