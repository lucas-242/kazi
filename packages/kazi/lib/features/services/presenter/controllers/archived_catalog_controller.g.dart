// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archived_catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How many services point at each archived catalog item — the number that
/// decides whether permanent deletion is offered at all.

@ProviderFor(ArchivedCatalogController)
const archivedCatalogControllerProvider = ArchivedCatalogControllerProvider._();

/// How many services point at each archived catalog item — the number that
/// decides whether permanent deletion is offered at all.
final class ArchivedCatalogControllerProvider
    extends $NotifierProvider<ArchivedCatalogController, ArchivedCatalogState> {
  /// How many services point at each archived catalog item — the number that
  /// decides whether permanent deletion is offered at all.
  const ArchivedCatalogControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedCatalogControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedCatalogControllerHash();

  @$internal
  @override
  ArchivedCatalogController create() => ArchivedCatalogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArchivedCatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArchivedCatalogState>(value),
    );
  }
}

String _$archivedCatalogControllerHash() =>
    r'c6f1f455fcbf5153d9981700abfa11db70b864e5';

/// How many services point at each archived catalog item — the number that
/// decides whether permanent deletion is offered at all.

abstract class _$ArchivedCatalogController
    extends $Notifier<ArchivedCatalogState> {
  ArchivedCatalogState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ArchivedCatalogState, ArchivedCatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ArchivedCatalogState, ArchivedCatalogState>,
              ArchivedCatalogState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
