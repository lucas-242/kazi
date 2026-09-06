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
    this.borderColor,
    this.width,
    this.height,
    this.labelStyle,
    this.padding,
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
    EdgeInsetsGeometry? padding,
  }) : this._(
          key: key,
          onTap: onTap,
          label: label,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          labelStyle: labelStyle,
          width: width,
          height: height,
          padding: padding,
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
    Color? borderColor,
    TextStyle? labelStyle,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) : this._(
          key: key,
          onTap: onTap,
          label: label,
          foregroundColor: foregroundColor,
          borderColor: borderColor,
          labelStyle: labelStyle,
          width: width,
          height: height,
          padding: padding,
          isOutlined: true,
        );

  final VoidCallback? onTap;
  final String? label;
  final TextStyle? labelStyle;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// The outline of `KaziElevatedButton.outlined`. Defaults to the label
  /// colour; pass a softer tint when the label is a saturated status colour
  /// that would over-weight the frame around it.
  final Color? borderColor;
  final double? width;
  final double? height;

  /// Room around the label. Left null the Material default applies, which is
  /// generous enough to wrap a long label in a narrow button.
  final EdgeInsetsGeometry? padding;

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
        padding: padding,
        elevation: 0,
        side: BorderSide(
          color: borderColor ?? foregroundColor ?? colors.borderStrong,
        ),
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(label!, style: labelStyle ?? KaziTextStyles.titleSmall),
          ),
        ),
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      // The brand yellow as a fill, with graphite ink on it — never the
      // surface colour, which would be 1.7:1.
      backgroundColor: backgroundColor ?? colors.brand.fill,
      foregroundColor: foregroundColor ?? colors.brand.onFill,
      padding: padding,
      elevation: 0,
      iconSize: KaziSizings.iconMd,
      shape: const RoundedRectangleBorder(
        borderRadius: KaziRadii.smBorder,
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                label!,
                style: labelStyle ?? KaziTextStyles.titleSmall,
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label!, style: labelStyle ?? KaziTextStyles.titleSmall),
        ),
      ),
    );
  }
}
