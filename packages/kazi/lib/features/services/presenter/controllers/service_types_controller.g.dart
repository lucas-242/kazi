// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_types_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceTypesController)
const serviceTypesControllerProvider = ServiceTypesControllerProvider._();

final class ServiceTypesControllerProvider
    extends $NotifierProvider<ServiceTypesController, ServiceTypesState> {
  const ServiceTypesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceTypesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceTypesControllerHash();

  @$internal
  @override
  ServiceTypesController create() => ServiceTypesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceTypesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceTypesState>(value),
    );
  }
}

String _$serviceTypesControllerHash() =>
    r'7d23a54bfe77745f80e341d3d25ff3e428ae5d61';

abstract class _$ServiceTypesController extends $Notifier<ServiceTypesState> {
  ServiceTypesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ServiceTypesState, ServiceTypesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServiceTypesState, ServiceTypesState>,
              ServiceTypesState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
