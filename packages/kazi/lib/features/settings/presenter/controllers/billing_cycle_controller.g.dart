// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_cycle_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's pay cycle, read from their account document.
///
/// Deliberately has no local-storage cache, unlike the default currency. The
/// currency needs one because its provider answers synchronously and would
/// render a wrong-but-plausible label for a frame; the cycle is awaited *before*
/// the dashboard fetch, while the page is already showing its loading state, so
/// a cache would buy nothing and cost a second source of truth to keep in sync.

@ProviderFor(BillingCycleController)
const billingCycleControllerProvider = BillingCycleControllerProvider._();

/// The user's pay cycle, read from their account document.
///
/// Deliberately has no local-storage cache, unlike the default currency. The
/// currency needs one because its provider answers synchronously and would
/// render a wrong-but-plausible label for a frame; the cycle is awaited *before*
/// the dashboard fetch, while the page is already showing its loading state, so
/// a cache would buy nothing and cost a second source of truth to keep in sync.
final class BillingCycleControllerProvider
    extends $AsyncNotifierProvider<BillingCycleController, BillingCycle> {
  /// The user's pay cycle, read from their account document.
  ///
  /// Deliberately has no local-storage cache, unlike the default currency. The
  /// currency needs one because its provider answers synchronously and would
  /// render a wrong-but-plausible label for a frame; the cycle is awaited *before*
  /// the dashboard fetch, while the page is already showing its loading state, so
  /// a cache would buy nothing and cost a second source of truth to keep in sync.
  const BillingCycleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingCycleControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingCycleControllerHash();

  @$internal
  @override
  BillingCycleController create() => BillingCycleController();
}

String _$billingCycleControllerHash() =>
    r'bdd187c50cc151c0e31a293e270106a67259676d';

/// The user's pay cycle, read from their account document.
///
/// Deliberately has no local-storage cache, unlike the default currency. The
/// currency needs one because its provider answers synchronously and would
/// render a wrong-but-plausible label for a frame; the cycle is awaited *before*
/// the dashboard fetch, while the page is already showing its loading state, so
/// a cache would buy nothing and cost a second source of truth to keep in sync.

abstract class _$BillingCycleController extends $AsyncNotifier<BillingCycle> {
  FutureOr<BillingCycle> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<BillingCycle>, BillingCycle>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BillingCycle>, BillingCycle>,
              AsyncValue<BillingCycle>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The effective cycle, falling back to the default while loading.

@ProviderFor(billingCycle)
const billingCycleProvider = BillingCycleProvider._();

/// The effective cycle, falling back to the default while loading.

final class BillingCycleProvider
    extends $FunctionalProvider<BillingCycle, BillingCycle, BillingCycle>
    with $Provider<BillingCycle> {
  /// The effective cycle, falling back to the default while loading.
  const BillingCycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingCycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingCycleHash();

  @$internal
  @override
  $ProviderElement<BillingCycle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BillingCycle create(Ref ref) {
    return billingCycle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingCycle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingCycle>(value),
    );
  }
}

String _$billingCycleHash() => r'a109b54ece208cbdd8bd8b111cf0fca6cbc7f326';
