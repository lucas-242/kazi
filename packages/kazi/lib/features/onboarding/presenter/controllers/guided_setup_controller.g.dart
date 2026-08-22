// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guided_setup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the five-step setup that seeds a catalog and registers a first
/// service. Write order, idempotency and the stalled-account rules are in
/// `features/onboarding/README.md`.

@ProviderFor(GuidedSetupController)
const guidedSetupControllerProvider = GuidedSetupControllerProvider._();

/// Drives the five-step setup that seeds a catalog and registers a first
/// service. Write order, idempotency and the stalled-account rules are in
/// `features/onboarding/README.md`.
final class GuidedSetupControllerProvider
    extends $AsyncNotifierProvider<GuidedSetupController, GuidedSetupState> {
  /// Drives the five-step setup that seeds a catalog and registers a first
  /// service. Write order, idempotency and the stalled-account rules are in
  /// `features/onboarding/README.md`.
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
    r'd43a0a8afc7007b19108c39cc73ce2b7b8257cbd';

/// Drives the five-step setup that seeds a catalog and registers a first
/// service. Write order, idempotency and the stalled-account rules are in
/// `features/onboarding/README.md`.

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
