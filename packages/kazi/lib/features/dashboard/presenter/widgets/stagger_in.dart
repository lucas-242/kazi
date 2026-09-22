import 'package:flutter/material.dart';

/// Fades and lifts a section into place once, [index] setting how far behind
/// the first one it starts. Never replays: `initState` runs once per position
/// in the tree, so a refresh or a receipt leaves it alone. See README.md.
class StaggerIn extends StatefulWidget {
  const StaggerIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> {
  static const _stagger = Duration(milliseconds: 70);
  static const _duration = Duration(milliseconds: 320);

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_stagger * widget.index, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final visible = _visible || reduceMotion;
    final duration = reduceMotion ? Duration.zero : _duration;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.06),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
