import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/buttons/buttons.dart';
import 'package:kazi/core/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/dashboard/presenter/widgets/dashboard_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DashboardState>(dashboardControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(dashboardControllerProvider);

    return CustomSafeArea(
      onRefresh: () =>
          ref.read(dashboardControllerProvider.notifier).onRefresh(),
      child: state.when(
        onState: (_) => DashboardContent(state: state),
        onLoading: () => const KaziLoading(),
        onNoData: () => KaziNoData(
          message: KaziLocalizations.current.noServicesHome,
          navbar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PillButton(
                onTap: () => KaziNavigator.push(AppPage.addServices),
                child: Text(KaziLocalizations.current.newService),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
