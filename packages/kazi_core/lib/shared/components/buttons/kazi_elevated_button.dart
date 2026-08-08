import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziElevatedButton extends StatelessWidget {
  const KaziElevatedButton._({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.labelStyle,
    bool isOutlined = false,
  }) : _isOutlined = isOutlined;

  const KaziElevatedButton.label({
    Key? key,
    VoidCallback? onTap,
    required String label,
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? labelStyle,
    double? width,
    double? height,
  }) : this._(
          key: key,
          onTap: onTap,
          label: label,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          labelStyle: labelStyle,
          width: width,
          height: height,
        );

  const KaziElevatedButton.icon({
    Key? key,
    VoidCallback? onTap,
    String? label,
    required Widget icon,
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? labelStyle,
    double? width,
    double? height,
  }) : this._(
          key: key,
          onTap: onTap,
          label: label,
          icon: icon,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          labelStyle: labelStyle,
          width: width,
          height: height,
        );

  const KaziElevatedButton.outlined({
    Key? key,
    VoidCallback? onTap,
    required String label,
    Color? foregroundColor,
    TextStyle? labelStyle,
    double? width,
    double? height,
  }) : this._(
          key: key,
          onTap: onTap,
          label: label,
          foregroundColor: foregroundColor,
          labelStyle: labelStyle,
          width: width,
          height: height,
          isOutlined: true,
        );

  final VoidCallback? onTap;
  final String? label;
  final TextStyle? labelStyle;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool _isOutlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorsScheme;
    final roles = context.kaziColors;

    if (_isOutlined) {
      final buttonStyle = OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? colors.onSurface,
        elevation: 0,
        side: BorderSide(color: foregroundColor ?? colors.outline),
        shape: const RoundedRectangleBorder(
          borderRadius: KaziRadii.xsBorder,
        ),
      );
      return OutlinedButton(
        key: key,
        onPressed: onTap,
        style: buttonStyle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
          child: Text(label!, style: labelStyle ?? KaziTextStyles.titleMd),
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      // The brand yellow as a fill, with graphite ink on it — never the
      // surface colour, which would be 1.7:1.
      backgroundColor: backgroundColor ?? roles.accentSurface,
      foregroundColor: foregroundColor ?? roles.onAccentSurface,
      elevation: 0,
      iconSize: KaziSizings.iconMd,
      shape: const RoundedRectangleBorder(
        borderRadius: KaziRadii.xsBorder,
      ),
    );

    if (icon != null) {
      if (label != null) {
        return ElevatedButton.icon(
          key: key,
          onPressed: onTap,
          icon: icon!,
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
            child: Text(label!, style: labelStyle ?? KaziTextStyles.titleMd),
          ),
          style: buttonStyle,
        );
      }

      return IconButton(
        key: key,
        onPressed: onTap,
        padding: const EdgeInsets.all(KaziInsets.sm),
        icon: icon!,
        style: buttonStyle,
      );
    }

    return ElevatedButton(
      key: key,
      onPressed: onTap,
      style: buttonStyle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
        child: Text(label!, style: labelStyle ?? KaziTextStyles.titleMd),
      ),
    );
  }
}
