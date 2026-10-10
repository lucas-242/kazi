// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_landing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceLandingController)
final serviceLandingControllerProvider = ServiceLandingControllerProvider._();

final class ServiceLandingControllerProvider
    extends $NotifierProvider<ServiceLandingController, ServiceLandingState> {
  ServiceLandingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceLandingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceLandingControllerHash();

  @$internal
  @override
  ServiceLandingController create() => ServiceLandingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceLandingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceLandingState>(value),
    );
  }
}

String _$serviceLandingControllerHash() =>
    r'dbd1bcf020420c5dee9f504b40fdfd87a2856940';

abstract class _$ServiceLandingController
    extends $Notifier<ServiceLandingState> {
  ServiceLandingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ServiceLandingState, ServiceLandingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServiceLandingState, ServiceLandingState>,
              ServiceLandingState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
