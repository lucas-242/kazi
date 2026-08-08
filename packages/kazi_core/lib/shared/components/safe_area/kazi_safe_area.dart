import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_padding_wrap.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_scroll_behavior.dart';
import 'package:kazi_core/shared/components/status/kazi_blocking_loading.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziSafeArea extends StatelessWidget {
  const KaziSafeArea({
    super.key,
    this.onRefresh,
    this.child,
    this.isScrollView = true,
    this.padding,
    this.physics = const BouncingScrollPhysics(),
    this.scrollController,
    this.isLoading = false,
    this.loadingColor,
  });

  final Future<void> Function()? onRefresh;
  final Widget? child;
  final EdgeInsets? padding;
  final bool isScrollView;
  final ScrollPhysics physics;
  final ScrollController? scrollController;

  final bool isLoading;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    return KaziBlockingLoading(
      isLoading: isLoading,
      color: loadingColor,
      child: SafeArea(
        child: ScrollConfiguration(
          behavior: KaziScrollBehavior(),
          child: onRefresh != null
              ? RefreshIndicator(
                  color: context.colorsScheme.onSurface,
                  backgroundColor: context.colorsScheme.surfaceContainerLowest,
                  onRefresh: onRefresh!,
                  child: _ScrollDecider(
                    isScrollView: isScrollView,
                    physics: physics,
                    scrollController: scrollController,
                    child: KaziPaddingWrap(
                      paddingLeft: padding?.left,
                      paddingRight: padding?.right,
                      paddingTop: padding?.top,
                      paddingBottom: padding?.bottom,
                      child: child,
                    ),
                  ),
                )
              : _ScrollDecider(
                  isScrollView: isScrollView,
                  physics: physics,
                  scrollController: scrollController,
                  child: KaziPaddingWrap(
                    paddingLeft: padding?.left,
                    paddingRight: padding?.right,
                    paddingTop: padding?.top,
                    paddingBottom: padding?.bottom,
                    child: child,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ScrollDecider extends StatelessWidget {
  const _ScrollDecider({
    required this.isScrollView,
    required this.physics,
    required this.child,
    this.scrollController,
  });

  final bool isScrollView;
  final ScrollPhysics physics;
  final Widget child;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (isScrollView) {
      return SingleChildScrollView(
        physics: physics,
        controller: scrollController,
        child: child,
      );
    } else {
      return child;
    }
  }
}
