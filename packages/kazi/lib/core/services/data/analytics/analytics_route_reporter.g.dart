// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_route_reporter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reports one screen view per navigation, to both sinks, and stamps the screen
/// on Crashlytics — so a failure reported deep in a repository still says where
/// the person was.
///
/// Deliberately not `PosthogObserver`: the shell is a
/// `StatefulShellRoute.indexedStack` where each tab owns its own `Navigator`, so
/// an observer on the root router never sees a push inside a tab and three
/// quarters of the app goes unmeasured.
///
/// Reports the [AppPage] name rather than the location, which keeps screen names
/// stable across route refactors and strips query strings that could carry an id.

@ProviderFor(analyticsRouteReporter)
final analyticsRouteReporterProvider = AnalyticsRouteReporterProvider._();

/// Reports one screen view per navigation, to both sinks, and stamps the screen
/// on Crashlytics — so a failure reported deep in a repository still says where
/// the person was.
///
/// Deliberately not `PosthogObserver`: the shell is a
/// `StatefulShellRoute.indexedStack` where each tab owns its own `Navigator`, so
/// an observer on the root router never sees a push inside a tab and three
/// quarters of the app goes unmeasured.
///
/// Reports the [AppPage] name rather than the location, which keeps screen names
/// stable across route refactors and strips query strings that could carry an id.

final class AnalyticsRouteReporterProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Reports one screen view per navigation, to both sinks, and stamps the screen
  /// on Crashlytics — so a failure reported deep in a repository still says where
  /// the person was.
  ///
  /// Deliberately not `PosthogObserver`: the shell is a
  /// `StatefulShellRoute.indexedStack` where each tab owns its own `Navigator`, so
  /// an observer on the root router never sees a push inside a tab and three
  /// quarters of the app goes unmeasured.
  ///
  /// Reports the [AppPage] name rather than the location, which keeps screen names
  /// stable across route refactors and strips query strings that could carry an id.
  AnalyticsRouteReporterProvider._()
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
    r'ff0dc3068534d034001ef9c3580d70fd9e0c2906';
