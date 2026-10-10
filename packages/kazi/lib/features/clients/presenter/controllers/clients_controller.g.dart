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
    extends $NotifierProvider<ClientsController, ClientsState> {
  ClientsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsControllerHash();

  @$internal
  @override
  ClientsController create() => ClientsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsState>(value),
    );
  }
}

String _$clientsControllerHash() => r'3c5afca69bbd9161443ae241d0edeac22b5cbe79';

abstract class _$ClientsController extends $Notifier<ClientsState> {
  ClientsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ClientsState, ClientsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientsState, ClientsState>,
              ClientsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
