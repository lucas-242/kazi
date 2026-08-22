// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localStorage)
const localStorageProvider = LocalStorageProvider._();

final class LocalStorageProvider extends $FunctionalProvider<
        AsyncValue<KaziLocalStorageService>,
        KaziLocalStorageService,
        FutureOr<KaziLocalStorageService>>
    with
        $FutureModifier<KaziLocalStorageService>,
        $FutureProvider<KaziLocalStorageService> {
  const LocalStorageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localStorageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localStorageHash();

  @$internal
  @override
  $FutureProviderElement<KaziLocalStorageService> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KaziLocalStorageService> create(Ref ref) {
    return localStorage(ref);
  }
}

String _$localStorageHash() => r'a22887f29baabfce0f5b947d0bac310e38bbdbcf';

@ProviderFor(inAppReviewService)
const inAppReviewServiceProvider = InAppReviewServiceProvider._();

final class InAppReviewServiceProvider extends $FunctionalProvider<
    KaziInAppReviewService,
    KaziInAppReviewService,
    KaziInAppReviewService> with $Provider<KaziInAppReviewService> {
  const InAppReviewServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inAppReviewServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inAppReviewServiceHash();

  @$internal
  @override
  $ProviderElement<KaziInAppReviewService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziInAppReviewService create(Ref ref) {
    return inAppReviewService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziInAppReviewService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziInAppReviewService>(value),
    );
  }
}

String _$inAppReviewServiceHash() =>
    r'cbdad94529cdec0025b320f7461ea57964836b4a';

@ProviderFor(kaziAppInfoService)
const kaziAppInfoServiceProvider = KaziAppInfoServiceProvider._();

final class KaziAppInfoServiceProvider extends $FunctionalProvider<
    KaziAppInfoService,
    KaziAppInfoService,
    KaziAppInfoService> with $Provider<KaziAppInfoService> {
  const KaziAppInfoServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziAppInfoServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziAppInfoServiceHash();

  @$internal
  @override
  $ProviderElement<KaziAppInfoService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziAppInfoService create(Ref ref) {
    return kaziAppInfoService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziAppInfoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziAppInfoService>(value),
    );
  }
}

String _$kaziAppInfoServiceHash() =>
    r'f7b6915d056345aae30e593124e56f13e74a0258';

@ProviderFor(kaziUrlLauncherService)
const kaziUrlLauncherServiceProvider = KaziUrlLauncherServiceProvider._();

final class KaziUrlLauncherServiceProvider extends $FunctionalProvider<
    KaziUrlLauncherService,
    KaziUrlLauncherService,
    KaziUrlLauncherService> with $Provider<KaziUrlLauncherService> {
  const KaziUrlLauncherServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziUrlLauncherServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziUrlLauncherServiceHash();

  @$internal
  @override
  $ProviderElement<KaziUrlLauncherService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziUrlLauncherService create(Ref ref) {
    return kaziUrlLauncherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziUrlLauncherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziUrlLauncherService>(value),
    );
  }
}

String _$kaziUrlLauncherServiceHash() =>
    r'79c96fcc48c7162ce972bc3ee7371432f3ac12e3';

@ProviderFor(inAppReviewManager)
const inAppReviewManagerProvider = InAppReviewManagerProvider._();

final class InAppReviewManagerProvider extends $FunctionalProvider<
        AsyncValue<KaziInAppReviewManager>,
        KaziInAppReviewManager,
        FutureOr<KaziInAppReviewManager>>
    with
        $FutureModifier<KaziInAppReviewManager>,
        $FutureProvider<KaziInAppReviewManager> {
  const InAppReviewManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inAppReviewManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inAppReviewManagerHash();

  @$internal
  @override
  $FutureProviderElement<KaziInAppReviewManager> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KaziInAppReviewManager> create(Ref ref) {
    return inAppReviewManager(ref);
  }
}

String _$inAppReviewManagerHash() =>
    r'4c6b2d65bae3d3c143be70618b7fb9ecaa274f23';

@ProviderFor(usersRepository)
const usersRepositoryProvider = UsersRepositoryProvider._();

final class UsersRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  const UsersRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'usersRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$usersRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return usersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$usersRepositoryHash() => r'48f837b62b5caa0cfac64728cc5514ddcf5c4354';

@ProviderFor(catalogItemRepositoy)
const catalogItemRepositoyProvider = CatalogItemRepositoyProvider._();

final class CatalogItemRepositoyProvider extends $FunctionalProvider<
    CatalogItemRepository,
    CatalogItemRepository,
    CatalogItemRepository> with $Provider<CatalogItemRepository> {
  const CatalogItemRepositoyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'catalogItemRepositoyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$catalogItemRepositoyHash();

  @$internal
  @override
  $ProviderElement<CatalogItemRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatalogItemRepository create(Ref ref) {
    return catalogItemRepositoy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogItemRepository>(value),
    );
  }
}

String _$catalogItemRepositoyHash() =>
    r'8a0045d547bd14a286075e15af84cd408f4930fb';

@ProviderFor(exchangeRateRepository)
const exchangeRateRepositoryProvider = ExchangeRateRepositoryProvider._();

final class ExchangeRateRepositoryProvider extends $FunctionalProvider<
    ExchangeRateRepository,
    ExchangeRateRepository,
    ExchangeRateRepository> with $Provider<ExchangeRateRepository> {
  const ExchangeRateRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exchangeRateRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExchangeRateRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExchangeRateRepository create(Ref ref) {
    return exchangeRateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExchangeRateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExchangeRateRepository>(value),
    );
  }
}

String _$exchangeRateRepositoryHash() =>
    r'32cb48ccf41148218a0eef988ffc3bdc9bcec1e4';

/// Shared store of daily rate snapshots. Overridden per app with a backed
/// implementation (kazi uses Firestore); the in-memory default keeps apps
/// without one working off the API alone.

@ProviderFor(exchangeRateHistoryRepository)
const exchangeRateHistoryRepositoryProvider =
    ExchangeRateHistoryRepositoryProvider._();

/// Shared store of daily rate snapshots. Overridden per app with a backed
/// implementation (kazi uses Firestore); the in-memory default keeps apps
/// without one working off the API alone.

final class ExchangeRateHistoryRepositoryProvider extends $FunctionalProvider<
        ExchangeRateHistoryRepository,
        ExchangeRateHistoryRepository,
        ExchangeRateHistoryRepository>
    with $Provider<ExchangeRateHistoryRepository> {
  /// Shared store of daily rate snapshots. Overridden per app with a backed
  /// implementation (kazi uses Firestore); the in-memory default keeps apps
  /// without one working off the API alone.
  const ExchangeRateHistoryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exchangeRateHistoryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExchangeRateHistoryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExchangeRateHistoryRepository create(Ref ref) {
    return exchangeRateHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExchangeRateHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<ExchangeRateHistoryRepository>(value),
    );
  }
}

String _$exchangeRateHistoryRepositoryHash() =>
    r'ed321d5a46aa5a2821d45c1ce3cdb3d2912085f1';

/// Resolves rates for any date.
///
/// **Kept alive on purpose:** this object owns the in-memory rate cache, so
/// disposing it would make every screen reload the local-storage cache and
/// re-hit the API. It is also what keeps its two dependencies above alive —
/// they are stateless and need no `keepAlive` of their own.

@ProviderFor(exchangeRateHistoryService)
const exchangeRateHistoryServiceProvider =
    ExchangeRateHistoryServiceProvider._();

/// Resolves rates for any date.
///
/// **Kept alive on purpose:** this object owns the in-memory rate cache, so
/// disposing it would make every screen reload the local-storage cache and
/// re-hit the API. It is also what keeps its two dependencies above alive —
/// they are stateless and need no `keepAlive` of their own.

final class ExchangeRateHistoryServiceProvider extends $FunctionalProvider<
        AsyncValue<ExchangeRateHistoryService>,
        ExchangeRateHistoryService,
        FutureOr<ExchangeRateHistoryService>>
    with
        $FutureModifier<ExchangeRateHistoryService>,
        $FutureProvider<ExchangeRateHistoryService> {
  /// Resolves rates for any date.
  ///
  /// **Kept alive on purpose:** this object owns the in-memory rate cache, so
  /// disposing it would make every screen reload the local-storage cache and
  /// re-hit the API. It is also what keeps its two dependencies above alive —
  /// they are stateless and need no `keepAlive` of their own.
  const ExchangeRateHistoryServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exchangeRateHistoryServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exchangeRateHistoryServiceHash();

  @$internal
  @override
  $FutureProviderElement<ExchangeRateHistoryService> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ExchangeRateHistoryService> create(Ref ref) {
    return exchangeRateHistoryService(ref);
  }
}

String _$exchangeRateHistoryServiceHash() =>
    r'0078b7d9c6cf91a87c777782cca25e080c44063a';

@ProviderFor(exchangeRates)
const exchangeRatesProvider = ExchangeRatesProvider._();

final class ExchangeRatesProvider extends $FunctionalProvider<
        AsyncValue<ExchangeRates?>, ExchangeRates?, FutureOr<ExchangeRates?>>
    with $FutureModifier<ExchangeRates?>, $FutureProvider<ExchangeRates?> {
  const ExchangeRatesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exchangeRatesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exchangeRatesHash();

  @$internal
  @override
  $FutureProviderElement<ExchangeRates?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ExchangeRates?> create(Ref ref) {
    return exchangeRates(ref);
  }
}

String _$exchangeRatesHash() => r'24ebaf6c02e0d718daa46c39b18a1c83970d8f7f';
