import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi_core/shared/navigation/kazi_auth.dart';
import 'package:kazi_core/shared/navigation/kazi_navigator.dart';
import 'package:kazi_core/shared/navigation/kazi_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_router.g.dart';

/// App-specific configuration consumed by the shared [kaziRouterProvider].
///
/// Each app injects its own instance by overriding [kaziRouterConfigProvider].
class KaziRouterConfig {
  const KaziRouterConfig({
    required this.routes,
    required this.initialLocation,
    required this.onboardingRoute,
    required this.loginRoute,
    required this.homeRoute,
    this.pageResolver,
    this.rootNavigatorKey,
  });

  final List<RouteBase> routes;
  final String initialLocation;
  final String onboardingRoute;
  final String loginRoute;
  final String homeRoute;
  final KaziPage? Function(String route)? pageResolver;
  final GlobalKey<NavigatorState>? rootNavigatorKey;
}

/// Overridable per app. Throws until an app injects its configuration.
@riverpod
KaziRouterConfig kaziRouterConfig(Ref ref) => throw UnimplementedError(
  'kaziRouterConfigProvider must be overridden per app',
);

/// Builds the shared [GoRouter] and wires [KaziNavigator] to it.
@riverpod
GoRouter kaziRouter(Ref ref) {
  final config = ref.watch(kaziRouterConfigProvider);
  final notifier = KaziRouterNotifier(ref, config);

  final router = GoRouter(
    initialLocation: config.initialLocation,
    navigatorKey: config.rootNavigatorKey,
    refreshListenable: notifier,
    redirect: (context, state) => notifier.redirect(state),
    routes: config.routes,
  );

  KaziNavigator.init(router, pageResolver: config.pageResolver);
  ref.onDispose(notifier.dispose);

  return router;
}

/// Drives redirects from the shared startup/auth providers.
final class KaziRouterNotifier extends ChangeNotifier {
  KaziRouterNotifier(this.ref, this.config) {
    ref.listen(kaziAppStartupProvider, (_, __) => notifyListeners());
    ref.listen(kaziIsAuthenticatedProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
  final KaziRouterConfig config;

  String? redirect(GoRouterState state) {
    final startup = ref.read(kaziAppStartupProvider);
    final auth = ref.read(kaziIsAuthenticatedProvider);

    // Stay on the splash while everything loads.
    if (startup.isLoading || auth.isLoading) {
      return state.uri.path == config.initialLocation
          ? null
          : config.initialLocation;
    }

    final startupState = startup.requireValue;

    switch (startupState) {
      case KaziStartupState.loading:
        return config.initialLocation;

      case KaziStartupState.onboarding:
        return state.uri.path != config.onboardingRoute
            ? config.onboardingRoute
            : null;

      case KaziStartupState.login:
        return state.uri.path != config.loginRoute ? config.loginRoute : null;

      case KaziStartupState.home:
        break;
    }

    final authenticated = auth.requireValue;

    if (!authenticated &&
        state.uri.path != config.loginRoute &&
        state.uri.path != config.onboardingRoute) {
      return config.loginRoute;
    }

    if (authenticated &&
        (state.uri.path == config.loginRoute ||
            state.uri.path == config.initialLocation)) {
      return config.homeRoute;
    }

    return null;
  }
}
