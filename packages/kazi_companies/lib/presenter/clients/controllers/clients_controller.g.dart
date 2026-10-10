// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientsController)
final clientsControllerProvider = ClientsControllerProvider._();

final class ClientsControllerProvider
    extends $AsyncNotifierProvider<ClientsController, ClientsState> {
  ClientsControllerProvider._()
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

String _$clientsControllerHash() => r'10e0895f502d552d338b0d4dd2effe7ef5850519';

abstract class _$ClientsController extends $AsyncNotifier<ClientsState> {
  FutureOr<ClientsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ClientsState>, ClientsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ClientsState>, ClientsState>,
        AsyncValue<ClientsState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
