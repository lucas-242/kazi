import 'package:kazi/features/dashboard/pages/dashboard_page.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class DashboardRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.home.route,
    builder: (_, _) => const DashboardPage(),
  );
}
