import 'package:kazi/app/views/home/pages/home_page.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class HomeRoutes {
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.home.route,
    builder: (_, _) => const HomePage(),
    routes: [...ServicesRoutes.nestedRoutes],
  );
}
