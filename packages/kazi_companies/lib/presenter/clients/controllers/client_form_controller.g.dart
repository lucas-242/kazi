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
    extends $AsyncNotifierProvider<ClientFormController, List<ServiceType>> {
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
    r'ad762beb6454f51fc1d532160327ca3214246e6d';

abstract class _$ClientFormController
    extends $AsyncNotifier<List<ServiceType>> {
  FutureOr<List<ServiceType>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ServiceType>>, List<ServiceType>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ServiceType>>, List<ServiceType>>,
        AsyncValue<List<ServiceType>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
