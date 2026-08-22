import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A compact on/off control.
///
/// Material's own `Switch` is 52×32 with an outlined track, which next to a
/// two-line settings row reads as the loudest thing on the screen. This one is
/// sized to the label beside it and carries the state in the brand fill alone.
class KaziSwitch extends StatelessWidget {
  const KaziSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _trackWidth = 44.0;
  static const _trackHeight = 26.0;
  static const _thumbSize = 20.0;
  static const _thumbInset = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Durations.short3,
          curve: Curves.easeOut,
          width: _trackWidth,
          height: _trackHeight,
          decoration: BoxDecoration(
            color: value ? colors.brand.fill : colors.surfaceStrong,
            borderRadius: KaziRadii.fullBorder,
          ),
          child: AnimatedAlign(
            duration: Durations.short3,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _thumbInset),
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: value ? colors.brand.onFill : colors.card,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
