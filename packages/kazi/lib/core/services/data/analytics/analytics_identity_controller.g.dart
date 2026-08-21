// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_identity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// This is what turns every funnel into a comparison. Without these properties
/// a funnel only says *that* people dropped out; with them it says *which*
/// people — the free ones, the ones on their third day, the ones whose totals
/// come out partial because a rate was missing.
///
/// Both sinks are given the same `distinctId` (the Firebase uid), so a PostHog
/// funnel and a Firebase audience are talking about the same person.
///
/// Nothing here throws: it is a listener on the side of the app, and a failure
/// to describe a user must never affect the user.

@ProviderFor(AnalyticsIdentityController)
const analyticsIdentityControllerProvider =
    AnalyticsIdentityControllerProvider._();

/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// This is what turns every funnel into a comparison. Without these properties
/// a funnel only says *that* people dropped out; with them it says *which*
/// people — the free ones, the ones on their third day, the ones whose totals
/// come out partial because a rate was missing.
///
/// Both sinks are given the same `distinctId` (the Firebase uid), so a PostHog
/// funnel and a Firebase audience are talking about the same person.
///
/// Nothing here throws: it is a listener on the side of the app, and a failure
/// to describe a user must never affect the user.
final class AnalyticsIdentityControllerProvider
    extends $AsyncNotifierProvider<AnalyticsIdentityController, void> {
  /// Keeps the analytics identity and its cohort attributes in sync with the app.
  ///
  /// This is what turns every funnel into a comparison. Without these properties
  /// a funnel only says *that* people dropped out; with them it says *which*
  /// people — the free ones, the ones on their third day, the ones whose totals
  /// come out partial because a rate was missing.
  ///
  /// Both sinks are given the same `distinctId` (the Firebase uid), so a PostHog
  /// funnel and a Firebase audience are talking about the same person.
  ///
  /// Nothing here throws: it is a listener on the side of the app, and a failure
  /// to describe a user must never affect the user.
  const AnalyticsIdentityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsIdentityControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsIdentityControllerHash();

  @$internal
  @override
  AnalyticsIdentityController create() => AnalyticsIdentityController();
}

String _$analyticsIdentityControllerHash() =>
    r'701e6af01512031e4c46422c063f7df9a84f6e14';

/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// This is what turns every funnel into a comparison. Without these properties
/// a funnel only says *that* people dropped out; with them it says *which*
/// people — the free ones, the ones on their third day, the ones whose totals
/// come out partial because a rate was missing.
///
/// Both sinks are given the same `distinctId` (the Firebase uid), so a PostHog
/// funnel and a Firebase audience are talking about the same person.
///
/// Nothing here throws: it is a listener on the side of the app, and a failure
/// to describe a user must never affect the user.

abstract class _$AnalyticsIdentityController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
