import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class KaziNavigationTransition {
  static CustomTransitionPage<T> customTransition<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    final Tween<Offset> bottomUpTween = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    );
    final Animatable<double> fastOutSlowInTween =
        CurveTween(curve: Curves.fastOutSlowIn);
    final Animatable<double> easeInTween = CurveTween(curve: Curves.easeIn);

    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(bottomUpTween.chain(fastOutSlowInTween)),
          child: FadeTransition(
            opacity: easeInTween.animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}
