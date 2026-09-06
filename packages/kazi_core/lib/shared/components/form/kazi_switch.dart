import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A compact on/off control.
///
/// Material's own `Switch` is 52×32 with an outlined track, which next to a
/// two-line settings row reads as the loudest thing on the screen. This one is
/// sized to the label beside it.
///
/// On is the inverse strip carrying the brand accent — a graphite track with a
/// yellow thumb on a light page, and the mirror of that on a dark one. A brand
/// *fill* track was the earlier shape and it spent the screen's one yellow on a
/// preference row.
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
            color: value ? colors.inverse : colors.surfaceStrong,
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
                  color: value ? colors.inverseAccent : colors.card,
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
