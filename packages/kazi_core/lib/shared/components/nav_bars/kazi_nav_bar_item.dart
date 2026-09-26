import 'package:flutter/material.dart';

/// One destination of a [KaziNavBar].
///
/// Pure data: the bar owns every visual decision, so a destination cannot
/// decorate itself out of the anatomy the brandbook fixes.
class KaziNavBarItem {
  const KaziNavBarItem({
    required this.icon,
    IconData? activeIcon,
    required this.label,
    this.semanticLabel,
  }) : activeIcon = activeIcon ?? icon;

  final IconData icon;

  /// Shown instead of [icon] for the active destination — a filled glyph so
  /// selection reads from the icon itself, not a mark drawn under the label.
  /// Defaults to [icon] for a destination with no filled counterpart.
  final IconData activeIcon;

  /// Always rendered. The bar has no icon-only mode by design.
  final String label;

  /// Announced instead of [label] when the label alone is ambiguous out of
  /// context.
  final String? semanticLabel;
}
