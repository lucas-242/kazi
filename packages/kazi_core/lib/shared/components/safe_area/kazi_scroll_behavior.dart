import 'package:flutter/material.dart';

/// A custom [ScrollBehavior] that removes the default overscroll indicator (glow effect) on Android and Fuchsia.
class KaziScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
