import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
