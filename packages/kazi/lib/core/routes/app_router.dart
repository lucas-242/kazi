import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/app_shell.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/is_authenticated_provider.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/app/views/home/home.dart';
import 'package:kazi/app/views/initial/intial.dart';
import 'package:kazi/app/views/login/login.dart';
import 'package:kazi/app/views/profile/profile.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi_core/kazi_core.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final routerProvider = Provider<GoRouter>((ref) {
    final router = RouterNotifier(ref);

    return GoRouter(
      initialLocation: AppPage.initial.route,
      refreshListenable: router,
      redirect: (context, state) => router.redirect(state),
      navigatorKey: _rootNavigatorKey,
      routes: buildRoutes(),
    );
  });

  static List<RouteBase> buildRoutes() => [
    ...SplashRoutes.routes,
    ...AuthRoutes.routes,
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        HomeRoutes.shellRoute(),
        ServicesRoutes.shellRoute(),
        ProfileRoutes.shellRoute(),
      ],
    ),
  ];
}

final class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(appStartupProvider, (_, _) => notifyListeners());
    ref.listen(isAuthenticatedProvider, (_, _) => notifyListeners());
  }

  final Ref ref;

  String? redirect(GoRouterState state) {
    final startup = ref.read(appStartupProvider);
    final auth = ref.read(isAuthenticatedProvider);

    // Continua na Splash enquanto tudo carrega
    if (startup.isLoading || auth.isLoading) {
      return state.uri.path == AppPage.initial.route
          ? null
          : AppPage.initial.route;
    }

    final startupState = startup.requireValue;

    switch (startupState) {
      case AppStartupState.loading:
        return AppPage.initial.route;

      case AppStartupState.onboarding:
        if (state.uri.path != AppPage.onboarding.route) {
          return AppPage.onboarding.route;
        }
        return null;

      case AppStartupState.login:
        if (state.uri.path != AppPage.login.route) {
          return AppPage.login.route;
        }
        return null;

      case AppStartupState.home:
        break;
    }

    final authenticated = auth.requireValue;

    if (!authenticated &&
        state.uri.path != AppPage.login.route &&
        state.uri.path != AppPage.onboarding.route) {
      return AppPage.login.route;
    }

    if (authenticated &&
        (state.uri.path == AppPage.login.route ||
            state.uri.path == AppPage.initial.route)) {
      return AppPage.home.route;
    }

    return null;
  }
}
