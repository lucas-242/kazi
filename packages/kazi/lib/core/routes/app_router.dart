import 'package:kazi/app_shell.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/navigation_keys.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/dashboard/dashboard.dart';
import 'package:kazi/features/onboarding/onboarding.dart';
import 'package:kazi/features/auth/auth.dart';
import 'package:kazi/features/settings/settings.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart';

class AppRouter {
  static KaziRouterConfig config() => KaziRouterConfig(
    routes: buildRoutes(),
    initialLocation: AppPage.initial.route,
    onboardingRoute: AppPage.onboarding.route,
    loginRoute: AppPage.login.route,
    homeRoute: AppPage.home.route,
    forcedUpdateRoute: AppPage.forcedUpdate.route,
    currencyMigrationRoute: AppPage.currencyMigration.route,
    pageResolver: AppPage.fromRoute,
    rootNavigatorKey: rootNavigatorKey,
  );

  static List<RouteBase> buildRoutes() => [
    ...OnboardingRoutes.routes,
    ...AuthRoutes.routes,
    ...AppUpdateRoutes.routes,
    ...SettingsRoutes.routes,
    // One branch per bottom-navigation tab: an IndexedStack keeps the three
    // tabs the person is not looking at alive, so switching back restores the
    // scroll position and the filters instead of rebuilding from scratch.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: homeBranchKey,
          routes: [DashboardRoutes.shellRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: servicesBranchKey,
          routes: [ServicesRoutes.shellRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: clientsBranchKey,
          routes: [ClientsRoutes.shellRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: menuBranchKey,
          routes: [SettingsRoutes.shellRoute()],
        ),
      ],
    ),
  ];
}
