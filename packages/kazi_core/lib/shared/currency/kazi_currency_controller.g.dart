// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_currency_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kaziCurrencyManager)
final kaziCurrencyManagerProvider = KaziCurrencyManagerProvider._();

final class KaziCurrencyManagerProvider extends $FunctionalProvider<
        AsyncValue<KaziCurrencyManager>,
        KaziCurrencyManager,
        FutureOr<KaziCurrencyManager>>
    with
        $FutureModifier<KaziCurrencyManager>,
        $FutureProvider<KaziCurrencyManager> {
  KaziCurrencyManagerProvider._()
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

/// Cross-device home for the default currency. Null keeps the local-only
/// behaviour; kazi overrides it with the user-document store.

@ProviderFor(kaziRemoteCurrencyStore)
final kaziRemoteCurrencyStoreProvider = KaziRemoteCurrencyStoreProvider._();

/// Cross-device home for the default currency. Null keeps the local-only
/// behaviour; kazi overrides it with the user-document store.

final class KaziRemoteCurrencyStoreProvider extends $FunctionalProvider<
    KaziRemoteCurrencyStore?,
    KaziRemoteCurrencyStore?,
    KaziRemoteCurrencyStore?> with $Provider<KaziRemoteCurrencyStore?> {
  /// Cross-device home for the default currency. Null keeps the local-only
  /// behaviour; kazi overrides it with the user-document store.
  KaziRemoteCurrencyStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziRemoteCurrencyStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziRemoteCurrencyStoreHash();

  @$internal
  @override
  $ProviderElement<KaziRemoteCurrencyStore?> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziRemoteCurrencyStore? create(Ref ref) {
    return kaziRemoteCurrencyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziRemoteCurrencyStore? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziRemoteCurrencyStore?>(value),
    );
  }
}

String _$kaziRemoteCurrencyStoreHash() =>
    r'7f4640e8b6125fa1cf87e7934c4178c4fb4fa318';

@ProviderFor(KaziCurrencyController)
final kaziCurrencyControllerProvider = KaziCurrencyControllerProvider._();

final class KaziCurrencyControllerProvider
    extends $AsyncNotifierProvider<KaziCurrencyController, SupportedCurrency> {
  KaziCurrencyControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziCurrencyControllerProvider',
          isAutoDispose: false,
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
    r'452872db972c840b794a79e742fd48e14b6c82c1';

abstract class _$KaziCurrencyController
    extends $AsyncNotifier<SupportedCurrency> {
  FutureOr<SupportedCurrency> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SupportedCurrency>, SupportedCurrency>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SupportedCurrency>, SupportedCurrency>,
        AsyncValue<SupportedCurrency>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Effective default currency, falling back to USD while loading.

@ProviderFor(kaziDefaultCurrency)
final kaziDefaultCurrencyProvider = KaziDefaultCurrencyProvider._();

/// Effective default currency, falling back to USD while loading.

final class KaziDefaultCurrencyProvider extends $FunctionalProvider<
    SupportedCurrency,
    SupportedCurrency,
    SupportedCurrency> with $Provider<SupportedCurrency> {
  /// Effective default currency, falling back to USD while loading.
  KaziDefaultCurrencyProvider._()
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
