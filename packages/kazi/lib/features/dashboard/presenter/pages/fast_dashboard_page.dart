import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/widgets/dashboard_content.dart';
import 'package:kazi/features/dashboard/presenter/widgets/dashboard_skeleton.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The home: a plain greeting header, the cycle's money on a floating card,
/// then what was done today. Layout and content decisions are in
/// `features/dashboard/README.md`.
class FastDashboardPage extends ConsumerStatefulWidget {
  const FastDashboardPage({super.key});

  @override
  ConsumerState<FastDashboardPage> createState() => _FastDashboardPageState();
}

class _FastDashboardPageState extends ConsumerState<FastDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    // Only the very first fetch has nothing to show behind it; `referenceDate`
    // is null exactly until that one resolves. See README.md.
    final isFirstLoad =
        state.status == BaseStateStatus.loading && state.referenceDate == null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.colors.overlayOn(context.colors.background),
      child: Scaffold(
        body: KaziSafeArea(
          padding: EdgeInsets.zero,
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).onRefresh(),
          child: isFirstLoad
              ? const DashboardSkeleton()
              : DashboardContent(state: state),
        ),
      ),
    );
  }
}
