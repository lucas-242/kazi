// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single place a service's status stamps are written — the payment stamp
/// and the cancellation.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.
///
/// `keepAlive` because the write is awaited: an auto-disposed writer has no
/// listener holding it, so the Ref is gone by the time Firestore answers and
/// every patch below throws.

@ProviderFor(ServiceStatusController)
const serviceStatusControllerProvider = ServiceStatusControllerProvider._();

/// The single place a service's status stamps are written — the payment stamp
/// and the cancellation.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.
///
/// `keepAlive` because the write is awaited: an auto-disposed writer has no
/// listener holding it, so the Ref is gone by the time Firestore answers and
/// every patch below throws.
final class ServiceStatusControllerProvider
    extends $NotifierProvider<ServiceStatusController, void> {
  /// The single place a service's status stamps are written — the payment stamp
  /// and the cancellation.
  ///
  /// One writer, two readers: the write goes to Firestore once, then both list
  /// controllers patch their own copy in memory. Refetching instead would depend
  /// on the write echo having landed — `ServicesRepository.get` reads
  /// cache-first — so the list could come back showing the state from before the
  /// tap. An in-memory patch is deterministic and instant.
  ///
  /// `keepAlive` because the write is awaited: an auto-disposed writer has no
  /// listener holding it, so the Ref is gone by the time Firestore answers and
  /// every patch below throws.
  const ServiceStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceStatusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceStatusControllerHash();

  @$internal
  @override
  ServiceStatusController create() => ServiceStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$serviceStatusControllerHash() =>
    r'7013852efd64352337b3c5097d303b8e9cdcd9ec';

/// The single place a service's status stamps are written — the payment stamp
/// and the cancellation.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.
///
/// `keepAlive` because the write is awaited: an auto-disposed writer has no
/// listener holding it, so the Ref is gone by the time Firestore answers and
/// every patch below throws.

abstract class _$ServiceStatusController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
