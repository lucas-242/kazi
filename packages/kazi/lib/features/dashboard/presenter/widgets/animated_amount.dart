import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A money [Text] that counts to a new [value] instead of jumping to it — the
/// number the user cannot work out in their head is worth a beat of motion
/// when it changes.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.value,
    required this.currency,
    required this.style,
  });

  final double value;
  final SupportedCurrency currency;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) => Text(
        NumberFormatUtils.formatCurrencyIn(animated, currency),
        style: style,
        maxLines: 1,
      ),
    );
  }
}
