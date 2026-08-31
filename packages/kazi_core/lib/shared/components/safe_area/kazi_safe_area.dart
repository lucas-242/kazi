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
    final isRefreshable = onRefresh != null;

    final content = _ScrollDecider(
      isScrollView: isScrollView,
      // A screen with nothing on it — an empty list, an error — is the one a
      // refresh is most wanted on, and it is also too short to overscroll:
      // without these two the gesture never reaches the indicator.
      physics: isRefreshable
          ? AlwaysScrollableScrollPhysics(parent: physics)
          : physics,
      fillsViewport: isRefreshable,
      scrollController: scrollController,
      child: KaziPaddingWrap(
        paddingLeft: padding?.left,
        paddingRight: padding?.right,
        paddingTop: padding?.top,
        paddingBottom: padding?.bottom,
        child: child,
      ),
    );

    return KaziBlockingLoading(
      isLoading: isLoading,
      color: loadingColor,
      child: SafeArea(
        child: ScrollConfiguration(
          behavior: KaziScrollBehavior(),
          child: isRefreshable
              ? RefreshIndicator(
                  color: context.colors.text,
                  backgroundColor: context.colors.card,
                  onRefresh: onRefresh!,
                  child: content,
                )
              : content,
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
    this.fillsViewport = false,
    this.scrollController,
  });

  final bool isScrollView;
  final ScrollPhysics physics;
  final Widget child;
  final bool fillsViewport;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (!isScrollView) {
      return child;
    }

    if (!fillsViewport) {
      return SingleChildScrollView(
        physics: physics,
        controller: scrollController,
        child: child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: physics,
        controller: scrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
          ),
          child: child,
        ),
      ),
    );
  }
}
