// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_receipt_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single place a payment stamp is written.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.

@ProviderFor(ServiceReceiptController)
const serviceReceiptControllerProvider = ServiceReceiptControllerProvider._();

/// The single place a payment stamp is written.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.
final class ServiceReceiptControllerProvider
    extends $NotifierProvider<ServiceReceiptController, void> {
  /// The single place a payment stamp is written.
  ///
  /// One writer, two readers: the write goes to Firestore once, then both list
  /// controllers patch their own copy in memory. Refetching instead would depend
  /// on the write echo having landed — `ServicesRepository.get` reads
  /// cache-first — so the list could come back showing the state from before the
  /// tap. An in-memory patch is deterministic and instant.
  const ServiceReceiptControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceReceiptControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceReceiptControllerHash();

  @$internal
  @override
  ServiceReceiptController create() => ServiceReceiptController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$serviceReceiptControllerHash() =>
    r'd7d2ace39ccdb57e7305890685582f4b58210ab5';

/// The single place a payment stamp is written.
///
/// One writer, two readers: the write goes to Firestore once, then both list
/// controllers patch their own copy in memory. Refetching instead would depend
/// on the write echo having landed — `ServicesRepository.get` reads
/// cache-first — so the list could come back showing the state from before the
/// tap. An in-memory patch is deterministic and instant.

abstract class _$ServiceReceiptController extends $Notifier<void> {
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
