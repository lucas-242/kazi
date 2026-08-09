import 'package:flutter/material.dart';

/// One destination of a [KaziNavBar].
///
/// Pure data: the bar owns every visual decision, so a destination cannot
/// decorate itself out of the anatomy the brandbook fixes.
class KaziNavBarItem {
  const KaziNavBarItem({
    required this.icon,
    required this.label,
    this.semanticLabel,
  });

  final IconData icon;

  /// Always rendered. The bar has no icon-only mode by design.
  final String label;

  /// Announced instead of [label] when the label alone is ambiguous out of
  /// context.
  final String? semanticLabel;
}
