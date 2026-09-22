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
    this.slivers,
    this.isScrollView = true,
    this.padding,
    this.physics = const BouncingScrollPhysics(),
    this.scrollController,
    this.isLoading = false,
    this.loadingColor,
  }) : assert(
         child == null || slivers == null,
         'Pass either a child or slivers, not both.',
       );

  final Future<void> Function()? onRefresh;
  final Widget? child;

  /// Lays the page out as a [CustomScrollView] of these, padded the way
  /// [child] would be, instead of scrolling one box. A list inside [child] is
  /// built, laid out and painted whole; as a sliver, only the rows on screen
  /// are. Ignores [isScrollView].
  final List<Widget>? slivers;

  final EdgeInsets? padding;
  final bool isScrollView;
  final ScrollPhysics physics;
  final ScrollController? scrollController;

  final bool isLoading;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    final isRefreshable = onRefresh != null;
    // A screen with nothing on it — an empty list, an error — is the one a
    // refresh is most wanted on, and it is also too short to overscroll:
    // without the always-scrollable physics (and, for a single box, filling
    // the viewport) the gesture never reaches the indicator.
    final scrollPhysics = isRefreshable
        ? AlwaysScrollableScrollPhysics(parent: physics)
        : physics;
    final slivers = this.slivers;

    // The bottom inset — the safe area, plus whatever room the shell's docked
    // button asks for — goes into the padding *inside* the scroll view, never
    // to [SafeArea]. As an outer inset it cuts the viewport short, and the
    // strip of page ground that leaves is exactly what the nav bar's notch
    // puts on show behind the button.
    //
    // A page that brings its own scroll view is handed the inset untouched
    // instead: a [ListView] with no padding of its own already pads itself
    // with `MediaQuery.padding`, and inside its own viewport at that.
    final ownsScroll = slivers != null || isScrollView;
    final bottomInset = ownsScroll ? MediaQuery.paddingOf(context).bottom : 0.0;
    final paddingBottom = (padding?.bottom ?? 0) + bottomInset;

    final content = slivers == null
        ? _ScrollDecider(
            isScrollView: isScrollView,
            physics: scrollPhysics,
            fillsViewport: isRefreshable,
            scrollController: scrollController,
            child: KaziPaddingWrap(
              paddingLeft: padding?.left,
              paddingRight: padding?.right,
              paddingTop: padding?.top,
              paddingBottom: paddingBottom,
              child: child,
            ),
          )
        : CustomScrollView(
            physics: scrollPhysics,
            controller: scrollController,
            slivers: [
              SliverPadding(
                padding: KaziPaddingWrap.paddingOf(
                  context,
                  left: padding?.left,
                  right: padding?.right,
                  top: padding?.top,
                  bottom: paddingBottom,
                ),
                sliver: SliverMainAxisGroup(slivers: slivers),
              ),
            ],
          );

    return KaziBlockingLoading(
      isLoading: isLoading,
      color: loadingColor,
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: ownsScroll,
        child: SafeArea(
          bottom: false,
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

    // A layer of its own: a scroll, or the keyboard resizing the viewport,
    // then moves the content instead of repainting every widget in it.
    if (!fillsViewport) {
      return SingleChildScrollView(
        physics: physics,
        controller: scrollController,
        child: RepaintBoundary(child: child),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: physics,
        controller: scrollController,
        child: RepaintBoundary(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
