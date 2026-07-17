import 'package:kazi/features/auth/pages/login_page.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

abstract final class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(path: AppPage.login.route, builder: (_, _) => const LoginPage()),
  ];
}
