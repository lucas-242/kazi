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
    this.currencyMigrationRoute,
    this.pageResolver,
    this.rootNavigatorKey,
  });

  final List<RouteBase> routes;
  final String initialLocation;
  final String onboardingRoute;
  final String loginRoute;
  final String homeRoute;
  final String? forcedUpdateRoute;
  final String? currencyMigrationRoute;
  final KaziPage? Function(String route)? pageResolver;
  final GlobalKey<NavigatorState>? rootNavigatorKey;
}

/// When it becomes `true` and the
/// config declares a [KaziRouterConfig.forcedUpdateRoute], the router locks the
/// user onto that route.
@riverpod
bool kaziForcedUpdateRequired(Ref ref) => false;

/// When it becomes `true` and the config declares a
/// [KaziRouterConfig.currencyMigrationRoute], the router locks the signed-in
/// user onto that route until they declare which currency their existing data
/// is in. It gates the home rather than prompting from it because every amount
/// on the home screen is meaningless until the answer is known.
@riverpod
bool kaziCurrencyMigrationRequired(Ref ref) => false;

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
    ref.listen(
      kaziCurrencyMigrationRequiredProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;
  final KaziRouterConfig config;

  String? redirect(GoRouterState state) {
    final startup = ref.read(kaziAppStartupProvider);
    final auth = ref.read(kaziIsAuthenticatedProvider);

    // Stay on the splash while everything loads
    if ((startup.isLoading && !startup.hasValue) ||
        (auth.isLoading && !auth.hasValue)) {
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
    final authenticated = auth.requireValue;

    if (!authenticated) {
      return state.uri.path != config.loginRoute ? config.loginRoute : null;
    }

    switch (startupState) {
      case KaziStartupState.loading:
        return config.initialLocation;

      case KaziStartupState.onboarding:
        return state.uri.path != config.onboardingRoute
            ? config.onboardingRoute
            : null;

      case KaziStartupState.login:
      case KaziStartupState.home:
        break;
    }

    // After auth and onboarding: it needs a signed-in user to migrate, and it
    // must not interrupt someone still creating their account.
    if (config.currencyMigrationRoute != null &&
        ref.read(kaziCurrencyMigrationRequiredProvider)) {
      return state.uri.path != config.currencyMigrationRoute
          ? config.currencyMigrationRoute
          : null;
    }

    if (state.uri.path == config.currencyMigrationRoute) {
      return config.homeRoute;
    }

    if (state.uri.path == config.loginRoute ||
        state.uri.path == config.initialLocation) {
      return config.homeRoute;
    }

    return null;
  }
}
