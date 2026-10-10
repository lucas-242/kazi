// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider = FirebaseFirestoreProvider._();

final class FirebaseFirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  FirebaseFirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseFirestoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseFirestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firebaseFirestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firebaseFirestoreHash() => r'211c9d7cd91051da8adfacbf85a09b8bad1d41e8';

@ProviderFor(crashlyticsService)
final crashlyticsServiceProvider = CrashlyticsServiceProvider._();

final class CrashlyticsServiceProvider
    extends
        $FunctionalProvider<
          CrashlyticsService,
          CrashlyticsService,
          CrashlyticsService
        >
    with $Provider<CrashlyticsService> {
  CrashlyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashlyticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashlyticsServiceHash();

  @$internal
  @override
  $ProviderElement<CrashlyticsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrashlyticsService create(Ref ref) {
    return crashlyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashlyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashlyticsService>(value),
    );
  }
}

String _$crashlyticsServiceHash() =>
    r'2764850f7dd6d635b4176f1d2145c3f839db7ad8';

@ProviderFor(firebaseAnalyticsSink)
final firebaseAnalyticsSinkProvider = FirebaseAnalyticsSinkProvider._();

final class FirebaseAnalyticsSinkProvider
    extends
        $FunctionalProvider<
          FirebaseAnalyticsService,
          FirebaseAnalyticsService,
          FirebaseAnalyticsService
        >
    with $Provider<FirebaseAnalyticsService> {
  FirebaseAnalyticsSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAnalyticsSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAnalyticsSinkHash();

  @$internal
  @override
  $ProviderElement<FirebaseAnalyticsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseAnalyticsService create(Ref ref) {
    return firebaseAnalyticsSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAnalyticsService>(value),
    );
  }
}

String _$firebaseAnalyticsSinkHash() =>
    r'2eddd9f4cea9b312d018da4a7198e9fc61453c28';

@ProviderFor(postHogAnalyticsSink)
final postHogAnalyticsSinkProvider = PostHogAnalyticsSinkProvider._();

final class PostHogAnalyticsSinkProvider
    extends
        $FunctionalProvider<
          PostHogAnalyticsService,
          PostHogAnalyticsService,
          PostHogAnalyticsService
        >
    with $Provider<PostHogAnalyticsService> {
  PostHogAnalyticsSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postHogAnalyticsSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postHogAnalyticsSinkHash();

  @$internal
  @override
  $ProviderElement<PostHogAnalyticsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PostHogAnalyticsService create(Ref ref) {
    return postHogAnalyticsSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostHogAnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostHogAnalyticsService>(value),
    );
  }
}

String _$postHogAnalyticsSinkHash() =>
    r'bab9bdd826a2d3b608f04584edf1981d1212aff1';

/// The only analytics dependency anything outside `core/services` should read.
/// It fans out to both sinks and applies the consent switch; see
/// [CompositeAnalyticsService].

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

/// The only analytics dependency anything outside `core/services` should read.
/// It fans out to both sinks and applies the consent switch; see
/// [CompositeAnalyticsService].

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  /// The only analytics dependency anything outside `core/services` should read.
  /// It fans out to both sinks and applies the consent switch; see
  /// [CompositeAnalyticsService].
  AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'46e2a8a74eb25cebc598815e10a670fc15465ee7';

@ProviderFor(sessionReplayPolicy)
final sessionReplayPolicyProvider = SessionReplayPolicyProvider._();

final class SessionReplayPolicyProvider
    extends
        $FunctionalProvider<
          SessionReplayPolicy,
          SessionReplayPolicy,
          SessionReplayPolicy
        >
    with $Provider<SessionReplayPolicy> {
  SessionReplayPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionReplayPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionReplayPolicyHash();

  @$internal
  @override
  $ProviderElement<SessionReplayPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionReplayPolicy create(Ref ref) {
    return sessionReplayPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionReplayPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionReplayPolicy>(value),
    );
  }
}

String _$sessionReplayPolicyHash() =>
    r'56c65e9a6f25cf5259274da09deaca4dbe71c3ff';

@ProviderFor(analyticsBootstrap)
final analyticsBootstrapProvider = AnalyticsBootstrapProvider._();

final class AnalyticsBootstrapProvider
    extends
        $FunctionalProvider<
          AnalyticsBootstrap,
          AnalyticsBootstrap,
          AnalyticsBootstrap
        >
    with $Provider<AnalyticsBootstrap> {
  AnalyticsBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsBootstrapHash();

  @$internal
  @override
  $ProviderElement<AnalyticsBootstrap> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalyticsBootstrap create(Ref ref) {
    return analyticsBootstrap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsBootstrap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsBootstrap>(value),
    );
  }
}

String _$analyticsBootstrapHash() =>
    r'436920a34542909780219c75836acdb14e5fb418';

/// Recognises a person struggling and promotes the session to being recorded.
/// Reports the event itself, so call sites only push the raw signal in.

@ProviderFor(frictionDetector)
final frictionDetectorProvider = FrictionDetectorProvider._();

/// Recognises a person struggling and promotes the session to being recorded.
/// Reports the event itself, so call sites only push the raw signal in.

final class FrictionDetectorProvider
    extends
        $FunctionalProvider<
          FrictionDetector,
          FrictionDetector,
          FrictionDetector
        >
    with $Provider<FrictionDetector> {
  /// Recognises a person struggling and promotes the session to being recorded.
  /// Reports the event itself, so call sites only push the raw signal in.
  FrictionDetectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frictionDetectorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frictionDetectorHash();

  @$internal
  @override
  $ProviderElement<FrictionDetector> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FrictionDetector create(Ref ref) {
    return frictionDetector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FrictionDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FrictionDetector>(value),
    );
  }
}

String _$frictionDetectorHash() => r'24757bd69dc44418b69f0dd4b1b64e77bcd1c62b';

@ProviderFor(timeService)
final timeServiceProvider = TimeServiceProvider._();

final class TimeServiceProvider
    extends $FunctionalProvider<TimeService, TimeService, TimeService>
    with $Provider<TimeService> {
  TimeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeServiceHash();

  @$internal
  @override
  $ProviderElement<TimeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimeService create(Ref ref) {
    return timeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeService>(value),
    );
  }
}

String _$timeServiceHash() => r'058240f9a624e47df05a9adeee6392ecf5435e45';

@ProviderFor(serviceOrganizer)
final serviceOrganizerProvider = ServiceOrganizerProvider._();

final class ServiceOrganizerProvider
    extends
        $FunctionalProvider<
          ServiceOrganizer,
          ServiceOrganizer,
          ServiceOrganizer
        >
    with $Provider<ServiceOrganizer> {
  ServiceOrganizerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceOrganizerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceOrganizerHash();

  @$internal
  @override
  $ProviderElement<ServiceOrganizer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServiceOrganizer create(Ref ref) {
    return serviceOrganizer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceOrganizer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceOrganizer>(value),
    );
  }
}

String _$serviceOrganizerHash() => r'718eeb1786c8e238e8a1fe2890551434da3669e1';

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'd30717fb3d28bf4cb1019c63fa2cf79e58581a89';

@ProviderFor(accountDataRepository)
final accountDataRepositoryProvider = AccountDataRepositoryProvider._();

final class AccountDataRepositoryProvider
    extends
        $FunctionalProvider<
          AccountDataRepository,
          AccountDataRepository,
          AccountDataRepository
        >
    with $Provider<AccountDataRepository> {
  AccountDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDataRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountDataRepository create(Ref ref) {
    return accountDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDataRepository>(value),
    );
  }
}

String _$accountDataRepositoryHash() =>
    r'526de129b6c86a2307269b799228e9b75eec5e49';

@ProviderFor(servicesRepository)
final servicesRepositoryProvider = ServicesRepositoryProvider._();

final class ServicesRepositoryProvider
    extends
        $FunctionalProvider<
          ServicesRepository,
          ServicesRepository,
          ServicesRepository
        >
    with $Provider<ServicesRepository> {
  ServicesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServicesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServicesRepository create(Ref ref) {
    return servicesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServicesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServicesRepository>(value),
    );
  }
}

String _$servicesRepositoryHash() =>
    r'c6bd61420333b22754748a46a49afad872851b1e';

/// Repairs the denormalized counters from the services themselves. Runs once
/// per account, in the background; see `core/counters.md`.

@ProviderFor(countersBackfill)
final countersBackfillProvider = CountersBackfillProvider._();

/// Repairs the denormalized counters from the services themselves. Runs once
/// per account, in the background; see `core/counters.md`.

final class CountersBackfillProvider
    extends
        $FunctionalProvider<
          CountersBackfill,
          CountersBackfill,
          CountersBackfill
        >
    with $Provider<CountersBackfill> {
  /// Repairs the denormalized counters from the services themselves. Runs once
  /// per account, in the background; see `core/counters.md`.
  CountersBackfillProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countersBackfillProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countersBackfillHash();

  @$internal
  @override
  $ProviderElement<CountersBackfill> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CountersBackfill create(Ref ref) {
    return countersBackfill(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CountersBackfill value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CountersBackfill>(value),
    );
  }
}

String _$countersBackfillHash() => r'ceb7ef12a2dd02814f47bb16732231a3c7df7570';

@ProviderFor(clientsRepository)
final clientsRepositoryProvider = ClientsRepositoryProvider._();

final class ClientsRepositoryProvider
    extends
        $FunctionalProvider<
          ClientsRepository,
          ClientsRepository,
          ClientsRepository
        >
    with $Provider<ClientsRepository> {
  ClientsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClientsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientsRepository create(Ref ref) {
    return clientsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsRepository>(value),
    );
  }
}

String _$clientsRepositoryHash() => r'375df9d62ed4b9e25d37c574fd15d239023ccc28';

@ProviderFor(catalogItemRepository)
final catalogItemRepositoryProvider = CatalogItemRepositoryProvider._();

final class CatalogItemRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogItemRepository,
          CatalogItemRepository,
          CatalogItemRepository
        >
    with $Provider<CatalogItemRepository> {
  CatalogItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogItemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogItemRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogItemRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogItemRepository create(Ref ref) {
    return catalogItemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogItemRepository>(value),
    );
  }
}

String _$catalogItemRepositoryHash() =>
    r'e280561a79351572daae37e5bcf945837519a7ed';

@ProviderFor(userSettingsRepository)
final userSettingsRepositoryProvider = UserSettingsRepositoryProvider._();

final class UserSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          UserSettingsRepository,
          UserSettingsRepository,
          UserSettingsRepository
        >
    with $Provider<UserSettingsRepository> {
  UserSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserSettingsRepository create(Ref ref) {
    return userSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettingsRepository>(value),
    );
  }
}

String _$userSettingsRepositoryHash() =>
    r'038836eafb35e87e3bd51586352c7d1c2c500ec4';

@ProviderFor(currencyMigrationRepository)
final currencyMigrationRepositoryProvider =
    CurrencyMigrationRepositoryProvider._();

final class CurrencyMigrationRepositoryProvider
    extends
        $FunctionalProvider<
          CurrencyMigrationRepository,
          CurrencyMigrationRepository,
          CurrencyMigrationRepository
        >
    with $Provider<CurrencyMigrationRepository> {
  CurrencyMigrationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyMigrationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyMigrationRepositoryHash();

  @$internal
  @override
  $ProviderElement<CurrencyMigrationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CurrencyMigrationRepository create(Ref ref) {
    return currencyMigrationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrencyMigrationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrencyMigrationRepository>(value),
    );
  }
}

String _$currencyMigrationRepositoryHash() =>
    r'87e6f3fdcaddcb38c23f0fcb36a644ec689388bb';

@ProviderFor(appRemoteCurrencyStore)
final appRemoteCurrencyStoreProvider = AppRemoteCurrencyStoreProvider._();

final class AppRemoteCurrencyStoreProvider
    extends
        $FunctionalProvider<
          KaziRemoteCurrencyStore,
          KaziRemoteCurrencyStore,
          KaziRemoteCurrencyStore
        >
    with $Provider<KaziRemoteCurrencyStore> {
  AppRemoteCurrencyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRemoteCurrencyStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRemoteCurrencyStoreHash();

  @$internal
  @override
  $ProviderElement<KaziRemoteCurrencyStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  KaziRemoteCurrencyStore create(Ref ref) {
    return appRemoteCurrencyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziRemoteCurrencyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziRemoteCurrencyStore>(value),
    );
  }
}

String _$appRemoteCurrencyStoreHash() =>
    r'5008b97b31b2ce3272f661f49677f169d1447470';

@ProviderFor(appExchangeRateHistoryRepository)
final appExchangeRateHistoryRepositoryProvider =
    AppExchangeRateHistoryRepositoryProvider._();

final class AppExchangeRateHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          ExchangeRateHistoryRepository,
          ExchangeRateHistoryRepository,
          ExchangeRateHistoryRepository
        >
    with $Provider<ExchangeRateHistoryRepository> {
  AppExchangeRateHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appExchangeRateHistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appExchangeRateHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExchangeRateHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExchangeRateHistoryRepository create(Ref ref) {
    return appExchangeRateHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExchangeRateHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExchangeRateHistoryRepository>(
        value,
      ),
    );
  }
}

String _$appExchangeRateHistoryRepositoryHash() =>
    r'd546ea619a51c69f0f52bec533805b6584daf6d4';

@ProviderFor(firebaseRemoteConfig)
final firebaseRemoteConfigProvider = FirebaseRemoteConfigProvider._();

final class FirebaseRemoteConfigProvider
    extends
        $FunctionalProvider<
          FirebaseRemoteConfig,
          FirebaseRemoteConfig,
          FirebaseRemoteConfig
        >
    with $Provider<FirebaseRemoteConfig> {
  FirebaseRemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseRemoteConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseRemoteConfigHash();

  @$internal
  @override
  $ProviderElement<FirebaseRemoteConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseRemoteConfig create(Ref ref) {
    return firebaseRemoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseRemoteConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseRemoteConfig>(value),
    );
  }
}

String _$firebaseRemoteConfigHash() =>
    r'558f490ba1ca6e87cc08e4c965455411ae7bd64a';

@ProviderFor(featureFlagService)
final featureFlagServiceProvider = FeatureFlagServiceProvider._();

final class FeatureFlagServiceProvider
    extends
        $FunctionalProvider<
          FeatureFlagService,
          FeatureFlagService,
          FeatureFlagService
        >
    with $Provider<FeatureFlagService> {
  FeatureFlagServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureFlagServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureFlagServiceHash();

  @$internal
  @override
  $ProviderElement<FeatureFlagService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeatureFlagService create(Ref ref) {
    return featureFlagService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureFlagService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureFlagService>(value),
    );
  }
}

String _$featureFlagServiceHash() =>
    r'6ad7ee26806175fa6be3f6052c68bc1238c21c55';

@ProviderFor(isPaymentsEnabled)
final isPaymentsEnabledProvider = IsPaymentsEnabledProvider._();

final class IsPaymentsEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsPaymentsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isPaymentsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isPaymentsEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isPaymentsEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isPaymentsEnabledHash() => r'1e2bf372c4f8bbc056a16c308c2f2fea4e22729c';

@ProviderFor(appUpdateService)
final appUpdateServiceProvider = AppUpdateServiceProvider._();

final class AppUpdateServiceProvider
    extends
        $FunctionalProvider<
          AppUpdateService,
          AppUpdateService,
          AppUpdateService
        >
    with $Provider<AppUpdateService> {
  AppUpdateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateServiceHash();

  @$internal
  @override
  $ProviderElement<AppUpdateService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppUpdateService create(Ref ref) {
    return appUpdateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateService>(value),
    );
  }
}

String _$appUpdateServiceHash() => r'39dcd2a5ce93be434ce66c791105b52ef0b82a6a';

@ProviderFor(subscriptionService)
final subscriptionServiceProvider = SubscriptionServiceProvider._();

final class SubscriptionServiceProvider
    extends
        $FunctionalProvider<
          SubscriptionService,
          SubscriptionService,
          SubscriptionService
        >
    with $Provider<SubscriptionService> {
  SubscriptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionServiceHash();

  @$internal
  @override
  $ProviderElement<SubscriptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubscriptionService create(Ref ref) {
    return subscriptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionService>(value),
    );
  }
}

String _$subscriptionServiceHash() =>
    r'79f551f8dc077947256eb11750660641d308be40';

@ProviderFor(entitlement)
final entitlementProvider = EntitlementProvider._();

final class EntitlementProvider
    extends
        $FunctionalProvider<
          AsyncValue<Entitlement>,
          Entitlement,
          Stream<Entitlement>
        >
    with $FutureModifier<Entitlement>, $StreamProvider<Entitlement> {
  EntitlementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementHash();

  @$internal
  @override
  $StreamProviderElement<Entitlement> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Entitlement> create(Ref ref) {
    return entitlement(ref);
  }
}

String _$entitlementHash() => r'ade3c6d2111ca5344eae7b8a5161d24980dd2f4a';

@ProviderFor(isPremium)
final isPremiumProvider = IsPremiumProvider._();

final class IsPremiumProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsPremiumProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isPremiumProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isPremiumHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isPremium(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isPremiumHash() => r'a54ae4190cea08c49fcca89c25778640f2137225';

@ProviderFor(adConsentService)
const adConsentServiceProvider = AdConsentServiceProvider._();

final class AdConsentServiceProvider
    extends
        $FunctionalProvider<
          AdConsentService,
          AdConsentService,
          AdConsentService
        >
    with $Provider<AdConsentService> {
  const AdConsentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adConsentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adConsentServiceHash();

  @$internal
  @override
  $ProviderElement<AdConsentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdConsentService create(Ref ref) {
    return adConsentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdConsentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdConsentService>(value),
    );
  }
}

String _$adConsentServiceHash() => r'ead9c7a1ca44177f783e78e782c0b3e55117e514';

@ProviderFor(interstitialAdService)
final interstitialAdServiceProvider = InterstitialAdServiceProvider._();

final class InterstitialAdServiceProvider
    extends
        $FunctionalProvider<
          InterstitialAdService,
          InterstitialAdService,
          InterstitialAdService
        >
    with $Provider<InterstitialAdService> {
  InterstitialAdServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interstitialAdServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interstitialAdServiceHash();

  @$internal
  @override
  $ProviderElement<InterstitialAdService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterstitialAdService create(Ref ref) {
    return interstitialAdService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterstitialAdService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterstitialAdService>(value),
    );
  }
}

String _$interstitialAdServiceHash() =>
    r'04d04d06de755f90ab1d22beb1af0f5cd5023179';

@ProviderFor(creationAdCoordinator)
final creationAdCoordinatorProvider = CreationAdCoordinatorProvider._();

final class CreationAdCoordinatorProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreationAdCoordinator>,
          CreationAdCoordinator,
          FutureOr<CreationAdCoordinator>
        >
    with
        $FutureModifier<CreationAdCoordinator>,
        $FutureProvider<CreationAdCoordinator> {
  CreationAdCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creationAdCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creationAdCoordinatorHash();

  @$internal
  @override
  $FutureProviderElement<CreationAdCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreationAdCoordinator> create(Ref ref) {
    return creationAdCoordinator(ref);
  }
}

String _$creationAdCoordinatorHash() =>
    r'4f54bb361f268ff3055556b8fc9a0174c1c90fd6';

@ProviderFor(bannerAdPolicy)
final bannerAdPolicyProvider = BannerAdPolicyProvider._();

final class BannerAdPolicyProvider
    extends $FunctionalProvider<BannerAdPolicy, BannerAdPolicy, BannerAdPolicy>
    with $Provider<BannerAdPolicy> {
  BannerAdPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bannerAdPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bannerAdPolicyHash();

  @$internal
  @override
  $ProviderElement<BannerAdPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BannerAdPolicy create(Ref ref) {
    return bannerAdPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BannerAdPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BannerAdPolicy>(value),
    );
  }
}

String _$bannerAdPolicyHash() => r'45d5ee531a1727623919a17118c3ede3dd795e30';

@ProviderFor(freemiumGuard)
final freemiumGuardProvider = FreemiumGuardProvider._();

final class FreemiumGuardProvider
    extends $FunctionalProvider<FreemiumGuard, FreemiumGuard, FreemiumGuard>
    with $Provider<FreemiumGuard> {
  FreemiumGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'freemiumGuardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$freemiumGuardHash();

  @$internal
  @override
  $ProviderElement<FreemiumGuard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FreemiumGuard create(Ref ref) {
    return freemiumGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FreemiumGuard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FreemiumGuard>(value),
    );
  }
}

String _$freemiumGuardHash() => r'b3954637874577d0acda931e2b74878e79f8542a';
