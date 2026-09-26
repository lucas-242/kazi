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
/// Someone active opens Kazi to record a job, not to configure it: this is a
/// dismissible card on the home, never a full screen or a modal. The currency
/// and the billing cycle are not asked here — the guided setup asks every
/// account once.

@ProviderFor(ActiveUserNudgesController)
const activeUserNudgesControllerProvider =
    ActiveUserNudgesControllerProvider._();

/// What the app asks of people who are already using it — which is as close to
/// nothing as the change allows.
///
/// Someone active opens Kazi to record a job, not to configure it: this is a
/// dismissible card on the home, never a full screen or a modal. The currency
/// and the billing cycle are not asked here — the guided setup asks every
/// account once.
final class ActiveUserNudgesControllerProvider
    extends
        $AsyncNotifierProvider<
          ActiveUserNudgesController,
          ActiveUserNudgesState
        > {
  /// What the app asks of people who are already using it — which is as close to
  /// nothing as the change allows.
  ///
  /// Someone active opens Kazi to record a job, not to configure it: this is a
  /// dismissible card on the home, never a full screen or a modal. The currency
  /// and the billing cycle are not asked here — the guided setup asks every
  /// account once.
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
    r'c8eeb86d177b040bb9f543cb4a7d384d612ef61d';

/// What the app asks of people who are already using it — which is as close to
/// nothing as the change allows.
///
/// Someone active opens Kazi to record a job, not to configure it: this is a
/// dismissible card on the home, never a full screen or a modal. The currency
/// and the billing cycle are not asked here — the guided setup asks every
/// account once.

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
