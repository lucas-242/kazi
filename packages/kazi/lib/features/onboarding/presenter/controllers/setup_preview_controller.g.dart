// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_preview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Debug only: the flow a rehearsal of the setup runs, or null for the real
/// setup. See `features/onboarding/README.md`.

@ProviderFor(SetupPreview)
const setupPreviewProvider = SetupPreviewProvider._();

/// Debug only: the flow a rehearsal of the setup runs, or null for the real
/// setup. See `features/onboarding/README.md`.
final class SetupPreviewProvider
    extends $NotifierProvider<SetupPreview, SetupFlow?> {
  /// Debug only: the flow a rehearsal of the setup runs, or null for the real
  /// setup. See `features/onboarding/README.md`.
  const SetupPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupPreviewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupPreviewHash();

  @$internal
  @override
  SetupPreview create() => SetupPreview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetupFlow? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetupFlow?>(value),
    );
  }
}

String _$setupPreviewHash() => r'880b4a072cf42a02489b9e3efd2d66a9df9ecaeb';

/// Debug only: the flow a rehearsal of the setup runs, or null for the real
/// setup. See `features/onboarding/README.md`.

abstract class _$SetupPreview extends $Notifier<SetupFlow?> {
  SetupFlow? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SetupFlow?, SetupFlow?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SetupFlow?, SetupFlow?>,
              SetupFlow?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
