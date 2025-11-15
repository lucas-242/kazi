import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class PaddingWrap extends StatelessWidget {
  const PaddingWrap({super.key, this.child, this.padding});

  final Widget? child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(
            left: KaziInsets.lg,
            right: KaziInsets.lg,
            top: KaziInsets.lg,
          ),
      child: child,
    );
  }
}
