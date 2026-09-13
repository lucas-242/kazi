import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/settings/kazi_palette.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A colour-coded initials avatar.
///
/// The background is deterministically derived from [name] using the same
/// 18-colour category palette catalog items use, so the same person always
/// gets the same colour without storing one. [imageUrl] takes over when set,
/// same as any other avatar.
class KaziAvatar extends StatelessWidget {
  const KaziAvatar({super.key, required this.name, this.imageUrl, this.radius = 20});

  final String name;
  final String? imageUrl;
  final double radius;

  static String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl case final url? when url.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url));
    }

    final background = context.colors.category(name.hashCode);
    // Category hues span light and dark; pick the ink that reads on
    // whichever one this name landed on, the same way `overlayOn` picks a
    // status-bar brightness.
    final isLight =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: Text(
        _initialsOf(name),
        style: KaziTextStyles.labelLarge.copyWith(
          color: isLight ? KaziPalette.graphite : KaziPalette.mist,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
