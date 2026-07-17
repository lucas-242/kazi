import 'package:kazi/app/app_shell.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/navigation_keys.dart';
import 'package:kazi/features/dashboard/dashboard.dart';
import 'package:kazi/features/onboarding/onboarding.dart';
import 'package:kazi/features/auth/auth.dart';
import 'package:kazi/features/profile/profile.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart';

class AppRouter {
  static KaziRouterConfig config() => KaziRouterConfig(
    routes: buildRoutes(),
    initialLocation: AppPage.initial.route,
    onboardingRoute: AppPage.onboarding.route,
    loginRoute: AppPage.login.route,
    homeRoute: AppPage.home.route,
    pageResolver: AppPage.fromRoute,
    rootNavigatorKey: rootNavigatorKey,
  );

  static List<RouteBase> buildRoutes() => [
    ...OnboardingRoutes.routes,
    ...AuthRoutes.routes,
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        DashboardRoutes.shellRoute(),
        ServicesRoutes.shellRoute(),
        ProfileRoutes.shellRoute(),
      ],
    ),
  ];
}
