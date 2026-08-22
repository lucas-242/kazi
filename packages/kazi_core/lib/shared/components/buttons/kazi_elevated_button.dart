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

  /// `width`/`height` are honoured here rather than through `minimumSize`, so
  /// `double.infinity` means "as wide as the parent allows" instead of an
  /// unsatisfiable constraint.
  Widget _sized(Widget button) => width == null && height == null
      ? button
      : SizedBox(width: width, height: height, child: button);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isOutlined) {
      final buttonStyle = OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? colors.text,
        elevation: 0,
        side: BorderSide(color: foregroundColor ?? colors.borderStrong),
        shape: const RoundedRectangleBorder(
          borderRadius: KaziRadii.xsBorder,
        ),
      );
      return _sized(
        OutlinedButton(
          key: key,
          onPressed: onTap,
          style: buttonStyle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
            child: Text(label!, style: labelStyle ?? KaziTextStyles.titleMedium),
          ),
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      // The brand yellow as a fill, with graphite ink on it — never the
      // surface colour, which would be 1.7:1.
      backgroundColor: backgroundColor ?? colors.brand.fill,
      foregroundColor: foregroundColor ?? colors.brand.onFill,
      elevation: 0,
      iconSize: KaziSizings.iconMd,
      shape: const RoundedRectangleBorder(
        borderRadius: KaziRadii.xsBorder,
      ),
    );

    if (icon != null) {
      if (label != null) {
        return _sized(
          ElevatedButton.icon(
            key: key,
            onPressed: onTap,
            icon: icon!,
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
              child: Text(
                label!,
                style: labelStyle ?? KaziTextStyles.titleMedium,
              ),
            ),
            style: buttonStyle,
          ),
        );
      }

      return _sized(
        IconButton(
          key: key,
          onPressed: onTap,
          padding: const EdgeInsets.all(KaziInsets.sm),
          icon: icon!,
          style: buttonStyle,
        ),
      );
    }

    return _sized(
      ElevatedButton(
        key: key,
        onPressed: onTap,
        style: buttonStyle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
          child: Text(label!, style: labelStyle ?? KaziTextStyles.titleMedium),
        ),
      ),
    );
  }
}
