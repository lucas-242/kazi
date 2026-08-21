// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_route_reporter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reports one screen view per navigation, to both sinks.
///
/// Deliberately **not** `PosthogObserver`. The app's shell is a
/// `StatefulShellRoute.indexedStack`, where each tab owns its own `Navigator`:
/// an observer attached to the root `GoRouter` never sees a push inside a tab,
/// so three quarters of the app would silently go unmeasured. Listening to the
/// router delegate sees every one of them, from a single place.
///
/// The name reported is the [AppPage] enum name, not the raw location. That
/// keeps screen names stable across route refactors, strips query strings that
/// could carry an id, and collapses `/services/service-details` to the page it
/// belongs to — which is the granularity a funnel is built at.

@ProviderFor(analyticsRouteReporter)
const analyticsRouteReporterProvider = AnalyticsRouteReporterProvider._();

/// Reports one screen view per navigation, to both sinks.
///
/// Deliberately **not** `PosthogObserver`. The app's shell is a
/// `StatefulShellRoute.indexedStack`, where each tab owns its own `Navigator`:
/// an observer attached to the root `GoRouter` never sees a push inside a tab,
/// so three quarters of the app would silently go unmeasured. Listening to the
/// router delegate sees every one of them, from a single place.
///
/// The name reported is the [AppPage] enum name, not the raw location. That
/// keeps screen names stable across route refactors, strips query strings that
/// could carry an id, and collapses `/services/service-details` to the page it
/// belongs to — which is the granularity a funnel is built at.

final class AnalyticsRouteReporterProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Reports one screen view per navigation, to both sinks.
  ///
  /// Deliberately **not** `PosthogObserver`. The app's shell is a
  /// `StatefulShellRoute.indexedStack`, where each tab owns its own `Navigator`:
  /// an observer attached to the root `GoRouter` never sees a push inside a tab,
  /// so three quarters of the app would silently go unmeasured. Listening to the
  /// router delegate sees every one of them, from a single place.
  ///
  /// The name reported is the [AppPage] enum name, not the raw location. That
  /// keeps screen names stable across route refactors, strips query strings that
  /// could carry an id, and collapses `/services/service-details` to the page it
  /// belongs to — which is the granularity a funnel is built at.
  const AnalyticsRouteReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsRouteReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsRouteReporterHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return analyticsRouteReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$analyticsRouteReporterHash() =>
    r'd58bb4945a524049f21fde24c7685f94c0fd2216';
