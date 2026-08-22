// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_user_nudges_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the app asks of people who are already using it — which is as close to
/// nothing as the change allows.
///
/// Someone active opens Kazi to record a job, not to configure it. Everything
/// here is a dismissible card on the home; there is no full screen, no modal,
/// and nothing that comes back on the next launch once answered.

@ProviderFor(ActiveUserNudgesController)
const activeUserNudgesControllerProvider =
    ActiveUserNudgesControllerProvider._();

/// What the app asks of people who are already using it — which is as close to
/// nothing as the change allows.
///
/// Someone active opens Kazi to record a job, not to configure it. Everything
/// here is a dismissible card on the home; there is no full screen, no modal,
/// and nothing that comes back on the next launch once answered.
final class ActiveUserNudgesControllerProvider
    extends
        $AsyncNotifierProvider<
          ActiveUserNudgesController,
          ActiveUserNudgesState
        > {
  /// What the app asks of people who are already using it — which is as close to
  /// nothing as the change allows.
  ///
  /// Someone active opens Kazi to record a job, not to configure it. Everything
  /// here is a dismissible card on the home; there is no full screen, no modal,
  /// and nothing that comes back on the next launch once answered.
  const ActiveUserNudgesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeUserNudgesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeUserNudgesControllerHash();

  @$internal
  @override
  ActiveUserNudgesController create() => ActiveUserNudgesController();
}

String _$activeUserNudgesControllerHash() =>
    r'e40e343a14c12d705cac32c54618646b03f5b6ea';

/// What the app asks of people who are already using it — which is as close to
/// nothing as the change allows.
///
/// Someone active opens Kazi to record a job, not to configure it. Everything
/// here is a dismissible card on the home; there is no full screen, no modal,
/// and nothing that comes back on the next launch once answered.

abstract class _$ActiveUserNudgesController
    extends $AsyncNotifier<ActiveUserNudgesState> {
  FutureOr<ActiveUserNudgesState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<ActiveUserNudgesState>, ActiveUserNudgesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ActiveUserNudgesState>,
                ActiveUserNudgesState
              >,
              AsyncValue<ActiveUserNudgesState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
