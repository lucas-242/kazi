// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_identity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// These properties are what turn a funnel into a comparison: without them it
/// says *that* people dropped out, with them it says *which*. Both sinks get the
/// Firebase uid as `distinctId`, so a PostHog funnel and a Firebase audience
/// describe the same person.

@ProviderFor(AnalyticsIdentityController)
const analyticsIdentityControllerProvider =
    AnalyticsIdentityControllerProvider._();

/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// These properties are what turn a funnel into a comparison: without them it
/// says *that* people dropped out, with them it says *which*. Both sinks get the
/// Firebase uid as `distinctId`, so a PostHog funnel and a Firebase audience
/// describe the same person.
final class AnalyticsIdentityControllerProvider
    extends $AsyncNotifierProvider<AnalyticsIdentityController, void> {
  /// Keeps the analytics identity and its cohort attributes in sync with the app.
  ///
  /// These properties are what turn a funnel into a comparison: without them it
  /// says *that* people dropped out, with them it says *which*. Both sinks get the
  /// Firebase uid as `distinctId`, so a PostHog funnel and a Firebase audience
  /// describe the same person.
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
    r'009804627da7d4c029e1050707396db53e71843c';

/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// These properties are what turn a funnel into a comparison: without them it
/// says *that* people dropped out, with them it says *which*. Both sinks get the
/// Firebase uid as `distinctId`, so a PostHog funnel and a Firebase audience
/// describe the same person.

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
