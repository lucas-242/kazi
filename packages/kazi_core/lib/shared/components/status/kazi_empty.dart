import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/images/kazi_svg.dart';
import 'package:kazi_core/shared/components/nav_bars/kazi_app_bar.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_safe_area.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A collection with nothing in it yet — the account's own absence of data, not
/// a filter that matched nothing. For the latter use `KaziNoResults`, which is
/// deliberately a different component: the brand block here would read as an
/// empty account and send the person looking for data they do have.
///
/// It invites rather than reports: the brand mark on a yellow block, a line
/// saying how the thing gets created, and an [action] that creates one.
class KaziEmpty extends StatelessWidget {
  const KaziEmpty({
    this.fullPage = false,
    this.scrollable = false,
    super.key,
    required this.message,
    this.description,
    this.action,
    this.onRefresh,
    this.title,
  }) : assert(
         !fullPage || title != null,
         'title must be provided when fullPage is true',
       );

  /// The headline: what would be here.
  final String message;

  /// How it gets here. One sentence, optional.
  final String? description;

  /// The button that creates the first one.
  final Widget? action;

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
    final content = _EmptyContent(
      message: message,
      description: description,
      action: action,
    );

    if (fullPage) {
      return Scaffold(
        appBar: KaziAppBar(title: title!),
        body: KaziSafeArea(onRefresh: onRefresh, child: content),
      );
    }

    if (scrollable) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(hasScrollBody: false, child: content),
        ],
      );
    }

    return content;
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({
    required this.message,
    required this.description,
    required this.action,
  });

  final String message;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KaziInsets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: KaziInsets.md,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.brand.fill,
                borderRadius: KaziRadii.mdBorder,
              ),
              child: KaziSvg(
                KaziSvgAssets.logo,
                height: 40,
                color: colors.brand.onFill,
              ),
            ),
            Text(
              message,
              style: KaziTextStyles.titleMedium.copyWith(color: colors.text),
              textAlign: TextAlign.center,
            ),
            if (description case final String text)
              Text(
                text,
                style: KaziTextStyles.bodyMedium.copyWith(
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            if (action case final Widget button) button,
          ],
        ),
      ),
    );
  }
}
