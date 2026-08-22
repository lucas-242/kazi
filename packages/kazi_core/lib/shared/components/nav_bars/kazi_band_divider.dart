import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The hairline that closes a header band, edge to edge.
///
/// It ignores the page's horizontal padding on purpose: a rule that stops
/// short of the screen edges reads as a border around the content below it
/// rather than as the end of the bar above it.
class KaziBandDivider extends StatelessWidget {
  const KaziBandDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: KaziInsets.lg,
      child: OverflowBox(
        maxWidth: context.width,
        child: Divider(height: KaziInsets.lg, color: context.colors.border),
      ),
    );
  }
}
