import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/dashboard/presenter/pages/fast_dashboard_page.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class DashboardRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.home.route,
    builder: (_, _) => const FastDashboardPage(),
  );
}
