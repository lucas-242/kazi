// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KaziLocaleController)
const kaziLocaleControllerProvider = KaziLocaleControllerProvider._();

final class KaziLocaleControllerProvider
    extends $AsyncNotifierProvider<KaziLocaleController, Locale?> {
  const KaziLocaleControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziLocaleControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziLocaleControllerHash();

  @$internal
  @override
  KaziLocaleController create() => KaziLocaleController();
}

String _$kaziLocaleControllerHash() =>
    r'4454c5a3bdc36849fac747bfdbdfe097558e5b80';

abstract class _$KaziLocaleController extends $AsyncNotifier<Locale?> {
  FutureOr<Locale?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Locale?>, Locale?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Locale?>, Locale?>,
        AsyncValue<Locale?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(kaziLocalePolicy)
const kaziLocalePolicyProvider = KaziLocalePolicyProvider._();

final class KaziLocalePolicyProvider extends $FunctionalProvider<
    KaziLocalePolicy,
    KaziLocalePolicy,
    KaziLocalePolicy> with $Provider<KaziLocalePolicy> {
  const KaziLocalePolicyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziLocalePolicyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziLocalePolicyHash();

  @$internal
  @override
  $ProviderElement<KaziLocalePolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziLocalePolicy create(Ref ref) {
    return kaziLocalePolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziLocalePolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziLocalePolicy>(value),
    );
  }
}

String _$kaziLocalePolicyHash() => r'56e5024161348c217cfcfe58e6e2ea57c13daa4e';

@ProviderFor(kaziLocaleManager)
const kaziLocaleManagerProvider = KaziLocaleManagerProvider._();

final class KaziLocaleManagerProvider extends $FunctionalProvider<
        AsyncValue<KaziLocaleManager>,
        KaziLocaleManager,
        FutureOr<KaziLocaleManager>>
    with
        $FutureModifier<KaziLocaleManager>,
        $FutureProvider<KaziLocaleManager> {
  const KaziLocaleManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziLocaleManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziLocaleManagerHash();

  @$internal
  @override
  $FutureProviderElement<KaziLocaleManager> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KaziLocaleManager> create(Ref ref) {
    return kaziLocaleManager(ref);
  }
}

String _$kaziLocaleManagerHash() => r'396664b95b04a4db637a94fb97561bead4b54747';

@ProviderFor(kaziLocaleResolutionCallback)
const kaziLocaleResolutionCallbackProvider =
    KaziLocaleResolutionCallbackProvider._();

final class KaziLocaleResolutionCallbackProvider extends $FunctionalProvider<
    KaziLocaleResolutionCallback,
    KaziLocaleResolutionCallback,
    KaziLocaleResolutionCallback> with $Provider<KaziLocaleResolutionCallback> {
  const KaziLocaleResolutionCallbackProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziLocaleResolutionCallbackProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziLocaleResolutionCallbackHash();

  @$internal
  @override
  $ProviderElement<KaziLocaleResolutionCallback> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziLocaleResolutionCallback create(Ref ref) {
    return kaziLocaleResolutionCallback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziLocaleResolutionCallback value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziLocaleResolutionCallback>(value),
    );
  }
}

String _$kaziLocaleResolutionCallbackHash() =>
    r'439df75f0472d4d265e10a7aa4c456bf4f6516b5';

@ProviderFor(kaziEffectiveLocale)
const kaziEffectiveLocaleProvider = KaziEffectiveLocaleProvider._();

final class KaziEffectiveLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale> with $Provider<Locale> {
  const KaziEffectiveLocaleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziEffectiveLocaleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziEffectiveLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return kaziEffectiveLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$kaziEffectiveLocaleHash() =>
    r'79e0efeba5f17b3d86788d40cb16742ee04273e6';
