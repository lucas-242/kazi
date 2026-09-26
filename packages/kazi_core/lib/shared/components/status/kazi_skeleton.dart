import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/kazi_category_bar.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// One inert placeholder block, pulsing while the data it stands for loads.
///
/// The pulse stops under "reduce motion", where the block renders flat.
class KaziSkeleton extends StatefulWidget {
  const KaziSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = KaziRadii.xsBorder,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<KaziSkeleton> createState() => _KaziSkeletonState();
}

class _KaziSkeletonState extends State<KaziSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final block = DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: widget.borderRadius,
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );

    if (MediaQuery.disableAnimationsOf(context)) return block;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: block,
    );
  }
}

/// The loading state of a list: [count] row-shaped skeletons standing in for
/// the rows that are coming.
///
/// Wrapped in an `AbsorbPointer`, which is what makes the loading surface
/// inert — the person sees that something is there and nothing answers, because
/// there is nothing to answer yet. Everything outside it (the bar, the FAB, the
/// chips) stays live on purpose. See `themes/README.md`.
class KaziSkeletonList extends StatelessWidget {
  const KaziSkeletonList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < count; index++) ...[
            if (index != 0) KaziSpacings.verticalXs,
            const _SkeletonRow(),
          ],
        ],
      ),
    );
  }
}

/// The shape of a list row: leading category bar, two lines of text, an amount.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: KaziRadii.smBorder,
        border: Border.all(color: colors.border),
      ),
      child: const IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KaziSkeleton(
              width: KaziCategoryBar.width,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: KaziInsets.md,
                  vertical: KaziInsets.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KaziSkeleton(width: 140, height: 12),
                          KaziSpacings.verticalXs,
                          KaziSkeleton(width: 96, height: 10),
                        ],
                      ),
                    ),
                    KaziSpacings.horizontalSm,
                    KaziSkeleton(width: 56, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
