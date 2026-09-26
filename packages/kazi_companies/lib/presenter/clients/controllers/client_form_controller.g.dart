// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientFormController)
const clientFormControllerProvider = ClientFormControllerProvider._();

final class ClientFormControllerProvider
    extends $AsyncNotifierProvider<ClientFormController, List<CatalogItem>> {
  const ClientFormControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'clientFormControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$clientFormControllerHash();

  @$internal
  @override
  ClientFormController create() => ClientFormController();
}

String _$clientFormControllerHash() =>
    r'3c945aa5e0dfac0c5fcd0ddd5b9a0cdb5a9d0253';

abstract class _$ClientFormController
    extends $AsyncNotifier<List<CatalogItem>> {
  FutureOr<List<CatalogItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<CatalogItem>>, List<CatalogItem>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<CatalogItem>>, List<CatalogItem>>,
        AsyncValue<List<CatalogItem>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
