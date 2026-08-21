import 'dart:async';

import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'analytics_route_reporter.g.dart';

/// Reports one screen view per navigation, to both sinks.
///
/// Deliberately not `PosthogObserver`: the shell is a
/// `StatefulShellRoute.indexedStack` where each tab owns its own `Navigator`, so
/// an observer on the root router never sees a push inside a tab and three
/// quarters of the app goes unmeasured.
///
/// Reports the [AppPage] name rather than the location, which keeps screen names
/// stable across route refactors and strips query strings that could carry an id.
@Riverpod(keepAlive: true)
void analyticsRouteReporter(Ref ref) {
  final router = ref.watch(kaziRouterProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  final delegate = router.routerDelegate;

  String? previous;

  void report() {
    // The delegate is the signal; the router's state is the answer. Its
    // `currentConfiguration` knows only the declarative match, so every pushed
    // full-screen route would be reported as the tab underneath it.
    //
    // `state` throws while the match list is empty, which is where the very
    // first call lands. Skipped rather than defaulted: the delegate notifies
    // again once there is a real location.
    final String location;
    try {
      location = router.state.uri.path;
    } catch (_) {
      return;
    }

    final page = AppPage.fromRoute(location);

    // The splash is the router deciding, not a destination, and it appears
    // mid-redirect on startup — reporting it would invent a `home → initial →
    // home` bounce. Skipped without touching `previous`, so both sides of the
    // redirect collapse into the one screen the person saw.
    if (page == AppPage.initial) return;

    // The delegate also notifies on shell rebuilds and dependency changes, and
    // a repeated screen view would make time-on-screen meaningless.
    if (page.name == previous) return;

    final from = previous;
    previous = page.name;

    unawaited(
      analytics.screen(page.name, parameters: {if (from != null) 'from': from}),
    );
  }

  delegate.addListener(report);
  ref.onDispose(() => delegate.removeListener(report));

  // The screen the app opens on is a navigation nobody notified us about.
  report();
}
