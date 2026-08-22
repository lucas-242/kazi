// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CatalogController)
const catalogControllerProvider = CatalogControllerProvider._();

final class CatalogControllerProvider
    extends $NotifierProvider<CatalogController, CatalogState> {
  const CatalogControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogControllerHash();

  @$internal
  @override
  CatalogController create() => CatalogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogState>(value),
    );
  }
}

String _$catalogControllerHash() => r'896d765c4486ade60200102dbd8815943a5dfeb9';

abstract class _$CatalogController extends $Notifier<CatalogState> {
  CatalogState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CatalogState, CatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CatalogState, CatalogState>,
              CatalogState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
