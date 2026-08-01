import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_padding_wrap.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_scroll_behavior.dart';
import 'package:kazi_core/shared/themes/settings/kazi_colors.dart';

class KaziSafeArea extends StatelessWidget {
  const KaziSafeArea({
    super.key,
    this.onRefresh,
    this.child,
    this.isScrollView = true,
    this.padding,
    this.physics = const BouncingScrollPhysics(),
    this.scrollController,
  });

  final Future<void> Function()? onRefresh;
  final Widget? child;
  final EdgeInsets? padding;
  final bool isScrollView;
  final ScrollPhysics physics;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: KaziScrollBehavior(),
        child: onRefresh != null
            ? RefreshIndicator(
                color: KaziColors.black,
                backgroundColor: KaziColors.white,
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
