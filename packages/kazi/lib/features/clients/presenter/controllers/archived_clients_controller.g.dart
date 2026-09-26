// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archived_clients_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArchivedClientsController)
const archivedClientsControllerProvider = ArchivedClientsControllerProvider._();

final class ArchivedClientsControllerProvider
    extends $NotifierProvider<ArchivedClientsController, ArchivedClientsState> {
  const ArchivedClientsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedClientsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedClientsControllerHash();

  @$internal
  @override
  ArchivedClientsController create() => ArchivedClientsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArchivedClientsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArchivedClientsState>(value),
    );
  }
}

String _$archivedClientsControllerHash() =>
    r'7844c5949106e72781bbf3a362199479a7aa4efa';

abstract class _$ArchivedClientsController
    extends $Notifier<ArchivedClientsState> {
  ArchivedClientsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ArchivedClientsState, ArchivedClientsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ArchivedClientsState, ArchivedClientsState>,
              ArchivedClientsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
