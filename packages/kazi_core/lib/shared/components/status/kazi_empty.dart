import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/nav_bars/kazi_app_bar.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_safe_area.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The centered "there is nothing here" message, for a screen or for the part
/// of one that a list would have filled.
class KaziEmpty extends StatelessWidget {
  const KaziEmpty({
    this.fullPage = false,
    this.scrollable = false,
    super.key,
    required this.message,
    this.onRefresh,
    this.title,
  }) : assert(
          !fullPage || title != null,
          'title must be provided when fullPage is true',
        );

  final String message;

  final bool fullPage;

  /// Gives the message a viewport of its own that always accepts the drag. Set
  /// it when this replaces a list under a `RefreshIndicator`: with nothing
  /// scrollable left on screen the pull never reaches the indicator, and an
  /// empty screen is where a refresh is wanted most. Needs a bounded height.
  final bool scrollable;

  /// Pull to refresh for the [fullPage] variant, which owns its own scaffold.
  final Future<void> Function()? onRefresh;

  final String? title;

  @override
  Widget build(BuildContext context) {
    if (fullPage) {
      return Scaffold(
        appBar: KaziAppBar(
          title: title!,
        ),
        body: KaziSafeArea(
          onRefresh: onRefresh,
          child: _EmptyContent(message: message),
        ),
      );
    }

    if (scrollable) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyContent(message: message),
          ),
        ],
      );
    }

    return _EmptyContent(message: message);
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: KaziInsets.sm,
        children: [
          Icon(
            Icons.block,
            size: 64,
            color: context.colors.scrim,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaziInsets.lg),
            child: Text(
              message,
              style: KaziTextStyles.headlineSmall.copyWith(
                color: context.colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          KaziSpacings.verticalLg,
        ],
      ),
    );
  }
}
