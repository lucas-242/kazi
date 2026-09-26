// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Decides whether a contextual hint may appear, and remembers that it did.
/// See `core/INTERRUPTIONS.md`.

@ProviderFor(HintController)
const hintControllerProvider = HintControllerProvider._();

/// Decides whether a contextual hint may appear, and remembers that it did.
/// See `core/INTERRUPTIONS.md`.
final class HintControllerProvider
    extends $NotifierProvider<HintController, void> {
  /// Decides whether a contextual hint may appear, and remembers that it did.
  /// See `core/INTERRUPTIONS.md`.
  const HintControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hintControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hintControllerHash();

  @$internal
  @override
  HintController create() => HintController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$hintControllerHash() => r'c8e788c7516862edba9d64f87d0c2ca416dc8323';

/// Decides whether a contextual hint may appear, and remembers that it did.
/// See `core/INTERRUPTIONS.md`.

abstract class _$HintController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
