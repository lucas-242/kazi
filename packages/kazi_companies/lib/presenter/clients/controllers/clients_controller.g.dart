// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientsController)
const clientsControllerProvider = ClientsControllerProvider._();

final class ClientsControllerProvider
    extends $AsyncNotifierProvider<ClientsController, List<ClientInfo>> {
  const ClientsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'clientsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$clientsControllerHash();

  @$internal
  @override
  ClientsController create() => ClientsController();
}

String _$clientsControllerHash() => r'a43cd6714346733a14dd8d36f182b7ea87724c81';

abstract class _$ClientsController extends $AsyncNotifier<List<ClientInfo>> {
  FutureOr<List<ClientInfo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ClientInfo>>, List<ClientInfo>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ClientInfo>>, List<ClientInfo>>,
        AsyncValue<List<ClientInfo>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
