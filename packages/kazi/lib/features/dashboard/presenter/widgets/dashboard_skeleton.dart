import 'package:flutter/material.dart';
import 'package:kazi/features/dashboard/presenter/widgets/dashboard_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Shaped like the real page rather than a spinner over it, from the same
/// blocks the Clients and Services lists use. Only the very first fetch gets
/// it — every later load already has content behind it. See README.md.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Padding(
        padding: DashboardContent.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                KaziSkeleton(width: 84, height: 20),
                KaziSkeleton(
                  width: 72,
                  height: 20,
                  borderRadius: KaziRadii.fullBorder,
                ),
              ],
            ),
            KaziSpacings.verticalMd,
            const KaziSkeleton(
              width: double.infinity,
              height: 172,
              borderRadius: KaziRadii.lgBorder,
            ),
            KaziSpacings.verticalMd,
            const Row(
              children: [
                Expanded(
                  child: KaziSkeleton(width: double.infinity, height: 72),
                ),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: KaziSkeleton(width: double.infinity, height: 72),
                ),
                KaziSpacings.horizontalSm,
                Expanded(
                  child: KaziSkeleton(width: double.infinity, height: 72),
                ),
              ],
            ),
            KaziSpacings.verticalMd,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KaziInsets.sm),
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                borderRadius: KaziRadii.lgBorder,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: KaziInsets.xs),
                    child: KaziSkeleton(width: 132, height: 14),
                  ),
                  KaziSpacings.verticalSm,
                  KaziSkeletonList(count: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
