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
    this.forcedUpdateRoute,
    this.pageResolver,
    this.rootNavigatorKey,
  });

  final List<RouteBase> routes;
  final String initialLocation;
  final String onboardingRoute;
  final String loginRoute;
  final String homeRoute;
  final String? forcedUpdateRoute;
  final KaziPage? Function(String route)? pageResolver;
  final GlobalKey<NavigatorState>? rootNavigatorKey;
}

/// When it becomes `true` and the
/// config declares a [KaziRouterConfig.forcedUpdateRoute], the router locks the
/// user onto that route.
@riverpod
bool kaziForcedUpdateRequired(Ref ref) => false;

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
    ref.listen(kaziForcedUpdateRequiredProvider, (_, __) => notifyListeners());
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

    // A mandatory update locks the user onto the forced-update route until they
    // update, taking precedence over onboarding/auth once startup resolves.
    if (config.forcedUpdateRoute != null &&
        ref.read(kaziForcedUpdateRequiredProvider)) {
      return state.uri.path != config.forcedUpdateRoute
          ? config.forcedUpdateRoute
          : null;
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
