// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_currency_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kaziCurrencyManager)
const kaziCurrencyManagerProvider = KaziCurrencyManagerProvider._();

final class KaziCurrencyManagerProvider extends $FunctionalProvider<
        AsyncValue<KaziCurrencyManager>,
        KaziCurrencyManager,
        FutureOr<KaziCurrencyManager>>
    with
        $FutureModifier<KaziCurrencyManager>,
        $FutureProvider<KaziCurrencyManager> {
  const KaziCurrencyManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziCurrencyManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziCurrencyManagerHash();

  @$internal
  @override
  $FutureProviderElement<KaziCurrencyManager> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KaziCurrencyManager> create(Ref ref) {
    return kaziCurrencyManager(ref);
  }
}

String _$kaziCurrencyManagerHash() =>
    r'adb42af816c3e0b8dcaf39c50ee18f44c277a526';

@ProviderFor(KaziCurrencyController)
const kaziCurrencyControllerProvider = KaziCurrencyControllerProvider._();

final class KaziCurrencyControllerProvider
    extends $AsyncNotifierProvider<KaziCurrencyController, SupportedCurrency> {
  const KaziCurrencyControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziCurrencyControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziCurrencyControllerHash();

  @$internal
  @override
  KaziCurrencyController create() => KaziCurrencyController();
}

String _$kaziCurrencyControllerHash() =>
    r'dff11289d72b94a94e3b0ef418bd0608c0145447';

abstract class _$KaziCurrencyController
    extends $AsyncNotifier<SupportedCurrency> {
  FutureOr<SupportedCurrency> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<SupportedCurrency>, SupportedCurrency>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SupportedCurrency>, SupportedCurrency>,
        AsyncValue<SupportedCurrency>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Effective default currency, falling back to USD while loading.

@ProviderFor(kaziDefaultCurrency)
const kaziDefaultCurrencyProvider = KaziDefaultCurrencyProvider._();

/// Effective default currency, falling back to USD while loading.

final class KaziDefaultCurrencyProvider extends $FunctionalProvider<
    SupportedCurrency,
    SupportedCurrency,
    SupportedCurrency> with $Provider<SupportedCurrency> {
  /// Effective default currency, falling back to USD while loading.
  const KaziDefaultCurrencyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziDefaultCurrencyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziDefaultCurrencyHash();

  @$internal
  @override
  $ProviderElement<SupportedCurrency> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupportedCurrency create(Ref ref) {
    return kaziDefaultCurrency(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupportedCurrency value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupportedCurrency>(value),
    );
  }
}

String _$kaziDefaultCurrencyHash() =>
    r'1c17e330c996c486480f3f6c27b127227c2bdd1e';
