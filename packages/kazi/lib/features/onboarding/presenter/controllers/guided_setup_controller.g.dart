// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guided_setup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the guided setup: the full flow that seeds a catalog and registers a
/// first service, or the essentials for an account that already has services.
/// Flows, write order and idempotency are in `features/onboarding/README.md`.

@ProviderFor(GuidedSetupController)
const guidedSetupControllerProvider = GuidedSetupControllerProvider._();

/// Drives the guided setup: the full flow that seeds a catalog and registers a
/// first service, or the essentials for an account that already has services.
/// Flows, write order and idempotency are in `features/onboarding/README.md`.
final class GuidedSetupControllerProvider
    extends $AsyncNotifierProvider<GuidedSetupController, GuidedSetupState> {
  /// Drives the guided setup: the full flow that seeds a catalog and registers a
  /// first service, or the essentials for an account that already has services.
  /// Flows, write order and idempotency are in `features/onboarding/README.md`.
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
    r'fad4866decd589fb59a87c9b30167a021d2c0ca7';

/// Drives the guided setup: the full flow that seeds a catalog and registers a
/// first service, or the essentials for an account that already has services.
/// Flows, write order and idempotency are in `features/onboarding/README.md`.

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
