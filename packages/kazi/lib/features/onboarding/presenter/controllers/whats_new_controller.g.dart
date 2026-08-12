// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whats_new_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Decides whether to announce the release, once.
///
/// Only to people already using the app: someone signing up today has no
/// "before" to compare against, and the guided setup already showed them
/// everything on the list.

@ProviderFor(WhatsNewController)
const whatsNewControllerProvider = WhatsNewControllerProvider._();

/// Decides whether to announce the release, once.
///
/// Only to people already using the app: someone signing up today has no
/// "before" to compare against, and the guided setup already showed them
/// everything on the list.
final class WhatsNewControllerProvider
    extends $NotifierProvider<WhatsNewController, void> {
  /// Decides whether to announce the release, once.
  ///
  /// Only to people already using the app: someone signing up today has no
  /// "before" to compare against, and the guided setup already showed them
  /// everything on the list.
  const WhatsNewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewControllerHash();

  @$internal
  @override
  WhatsNewController create() => WhatsNewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$whatsNewControllerHash() =>
    r'1a6c3e3ab440c00e39f6efb0e82ae144eaee8f04';

/// Decides whether to announce the release, once.
///
/// Only to people already using the app: someone signing up today has no
/// "before" to compare against, and the guided setup already showed them
/// everything on the list.

abstract class _$WhatsNewController extends $Notifier<void> {
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
