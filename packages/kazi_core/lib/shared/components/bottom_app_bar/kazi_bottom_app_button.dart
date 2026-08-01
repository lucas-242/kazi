import 'dart:math' show pow;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// Visual style used by [KaziNavButton] to lay out its icon and label.
///
/// - [google]: the label slides out horizontally next to the icon when active.
/// - [oldSchool]: the label sits statically below the icon.
enum KaziBottomAppBarStyle { google, oldSchool }

/// A single tab rendered inside [KaziBottomAppBar].
///
/// Shows an icon that, when [active], animates to reveal its [text] label. The
/// animation layout is driven by [style]. Instances are also used by
/// [KaziBottomAppBar] as lightweight configuration holders: the bar reads each tab's
/// properties and rebuilds it, falling back to bar-level defaults for any value
/// left null — so every visual field is intentionally nullable.
class KaziBottomAppButton extends StatefulWidget {
  const KaziBottomAppButton({
    super.key,
    required this.icon,
    this.text = '',
    this.active,
    this.haptic,
    this.debug,
    this.gap,
    this.iconSize,
    this.iconColor,
    this.iconActiveColor,
    this.textColor,
    this.textStyle,
    this.textSize,
    this.backgroundColor,
    this.backgroundGradient,
    this.rippleColor,
    this.hoverColor,
    this.padding,
    this.margin,
    this.duration,
    this.curve,
    this.leading,
    this.onPressed,
    this.borderRadius,
    this.border,
    this.activeBorder,
    this.shadow,
    this.semanticLabel,
    this.style = KaziBottomAppBarStyle.google,
  });

  final IconData icon;
  final String text;
  final bool? active;
  final bool? haptic;
  final bool? debug;
  final double? gap;
  final double? iconSize;
  final Color? iconColor;
  final Color? iconActiveColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double? textSize;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? rippleColor;
  final Color? hoverColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration? duration;
  final Curve? curve;
  final Widget? leading;
  final VoidCallback? onPressed;
  final BorderRadius? borderRadius;
  final Border? border;
  final Border? activeBorder;
  final List<BoxShadow>? shadow;
  final String? semanticLabel;
  final KaziBottomAppBarStyle? style;

  @override
  State<KaziBottomAppButton> createState() => _KaziBottomAppButtonState();
}

class _KaziBottomAppButtonState extends State<KaziBottomAppButton>
    with TickerProviderStateMixin {
  static const Duration _defaultDuration = Duration(milliseconds: 500);
  static const Curve _defaultCurve = Curves.easeInCubic;

  late bool _expanded;
  late final AnimationController _expandController;

  Duration get _duration => widget.duration ?? _defaultDuration;
  Curve get _curve => widget.curve ?? _defaultCurve;
  double get _gap => widget.gap ?? 0;
  bool get _active => widget.active ?? false;

  @override
  void initState() {
    super.initState();
    _expanded = _active;
    _expandController = AnimationController(vsync: this, duration: _duration)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double curveValue = _expandController
        .drive(CurveTween(curve: _expanded ? _curve : _curve.flipped))
        .value;
    final ColorTween colorTween =
        ColorTween(begin: widget.iconColor, end: widget.iconActiveColor);
    final Animation<Color?> colorTweenAnimation = colorTween.animate(
      CurvedAnimation(
        parent: _expandController,
        curve: _expanded ? Curves.easeInExpo : Curves.easeOutCirc,
      ),
    );

    _expanded = !_active;
    if (_expanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }

    final Widget icon = widget.leading ??
        Icon(
          widget.icon,
          color: colorTweenAnimation.value,
          size: widget.iconSize,
        );

    final Widget label = Text(
      widget.text,
      style: widget.textStyle ??
          TextStyle(fontWeight: FontWeight.w600, color: widget.textColor),
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: widget.hoverColor,
          splashColor: widget.rippleColor,
          borderRadius: widget.borderRadius,
          onTap: () {
            if (widget.haptic ?? true) HapticFeedback.selectionClick();
            widget.onPressed?.call();
          },
          child: Container(
            padding: widget.margin,
            child: AnimatedContainer(
              curve: Curves.easeOut,
              padding: widget.padding,
              duration: _duration,
              decoration: BoxDecoration(
                boxShadow: widget.shadow,
                border: _active
                    ? (widget.activeBorder ?? widget.border)
                    : widget.border,
                gradient: widget.backgroundGradient,
                color: _expanded
                    ? widget.backgroundColor?.withValues(alpha: 0)
                    : (widget.debug ?? false)
                        ? Colors.red
                        : widget.backgroundGradient != null
                            ? Colors.white
                            : widget.backgroundColor,
                borderRadius: widget.borderRadius,
              ),
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child:
                    _buildContent(icon, label, curveValue, colorTweenAnimation),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    Widget icon,
    Widget label,
    double curveValue,
    Animation<Color?> colorTweenAnimation,
  ) {
    switch (widget.style ?? KaziBottomAppBarStyle.google) {
      case KaziBottomAppBarStyle.google:
        return Stack(
          children: [
            if (widget.text.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Opacity(opacity: 0, child: icon),
                  Align(
                    alignment: Alignment.centerRight,
                    widthFactor: curveValue,
                    child: Opacity(
                      opacity: _expanded
                          ? pow(_expandController.value, 13) as double
                          : _expandController
                              .drive(CurveTween(curve: Curves.easeIn))
                              .value,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: _gap +
                              8 -
                              (8 *
                                  _expandController
                                      .drive(
                                        CurveTween(curve: Curves.easeOutSine),
                                      )
                                      .value),
                          right: 8 *
                              _expandController
                                  .drive(CurveTween(curve: Curves.easeOutSine))
                                  .value,
                        ),
                        child: label,
                      ),
                    ),
                  ),
                ],
              ),
            Align(alignment: Alignment.centerLeft, child: icon),
          ],
        );
      case KaziBottomAppBarStyle.oldSchool:
        return Column(
          children: [
            icon,
            Container(
              padding: EdgeInsets.only(top: _gap),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: colorTweenAnimation.value,
                  fontSize: widget.textSize ?? 16,
                ),
              ),
            ),
          ],
        );
    }
  }
}
