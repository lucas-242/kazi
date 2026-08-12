// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guided_setup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ninety seconds between signing in and seeing a real number.
///
/// The app only starts making sense once a service type with a commission
/// exists and one service has been registered. Before that the home opens on a
/// zero and answers nothing. This does not explain the product — it makes the
/// product work, and then shows the user their own money.

@ProviderFor(GuidedSetupController)
const guidedSetupControllerProvider = GuidedSetupControllerProvider._();

/// The ninety seconds between signing in and seeing a real number.
///
/// The app only starts making sense once a service type with a commission
/// exists and one service has been registered. Before that the home opens on a
/// zero and answers nothing. This does not explain the product — it makes the
/// product work, and then shows the user their own money.
final class GuidedSetupControllerProvider
    extends $AsyncNotifierProvider<GuidedSetupController, GuidedSetupState> {
  /// The ninety seconds between signing in and seeing a real number.
  ///
  /// The app only starts making sense once a service type with a commission
  /// exists and one service has been registered. Before that the home opens on a
  /// zero and answers nothing. This does not explain the product — it makes the
  /// product work, and then shows the user their own money.
  const GuidedSetupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guidedSetupControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guidedSetupControllerHash();

  @$internal
  @override
  GuidedSetupController create() => GuidedSetupController();
}

String _$guidedSetupControllerHash() =>
    r'311b14dffa765ec70e766eea512c1d2c9435522d';

/// The ninety seconds between signing in and seeing a real number.
///
/// The app only starts making sense once a service type with a commission
/// exists and one service has been registered. Before that the home opens on a
/// zero and answers nothing. This does not explain the product — it makes the
/// product work, and then shows the user their own money.

abstract class _$GuidedSetupController
    extends $AsyncNotifier<GuidedSetupState> {
  FutureOr<GuidedSetupState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<GuidedSetupState>, GuidedSetupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GuidedSetupState>, GuidedSetupState>,
              AsyncValue<GuidedSetupState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
