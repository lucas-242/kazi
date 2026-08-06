// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseFirestore)
const firebaseFirestoreProvider = FirebaseFirestoreProvider._();

final class FirebaseFirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  const FirebaseFirestoreProvider._()
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
const crashlyticsServiceProvider = CrashlyticsServiceProvider._();

final class CrashlyticsServiceProvider
    extends
        $FunctionalProvider<
          CrashlyticsService,
          CrashlyticsService,
          CrashlyticsService
        >
    with $Provider<CrashlyticsService> {
  const CrashlyticsServiceProvider._()
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

@ProviderFor(timeService)
const timeServiceProvider = TimeServiceProvider._();

final class TimeServiceProvider
    extends $FunctionalProvider<TimeService, TimeService, TimeService>
    with $Provider<TimeService> {
  const TimeServiceProvider._()
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

@ProviderFor(servicesService)
const servicesServiceProvider = ServicesServiceProvider._();

final class ServicesServiceProvider
    extends
        $FunctionalProvider<ServicesService, ServicesService, ServicesService>
    with $Provider<ServicesService> {
  const ServicesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicesServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicesServiceHash();

  @$internal
  @override
  $ProviderElement<ServicesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServicesService create(Ref ref) {
    return servicesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServicesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServicesService>(value),
    );
  }
}

String _$servicesServiceHash() => r'aff6275bb90e7ac5e948bdbfecb4b38070143dab';

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  const AuthServiceProvider._()
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

@ProviderFor(servicesRepository)
const servicesRepositoryProvider = ServicesRepositoryProvider._();

final class ServicesRepositoryProvider
    extends
        $FunctionalProvider<
          ServicesRepository,
          ServicesRepository,
          ServicesRepository
        >
    with $Provider<ServicesRepository> {
  const ServicesRepositoryProvider._()
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

@ProviderFor(clientsRepository)
const clientsRepositoryProvider = ClientsRepositoryProvider._();

final class ClientsRepositoryProvider
    extends
        $FunctionalProvider<
          ClientsRepository,
          ClientsRepository,
          ClientsRepository
        >
    with $Provider<ClientsRepository> {
  const ClientsRepositoryProvider._()
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

@ProviderFor(serviceTypeRepository)
const serviceTypeRepositoryProvider = ServiceTypeRepositoryProvider._();

final class ServiceTypeRepositoryProvider
    extends
        $FunctionalProvider<
          ServiceTypeRepository,
          ServiceTypeRepository,
          ServiceTypeRepository
        >
    with $Provider<ServiceTypeRepository> {
  const ServiceTypeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceTypeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceTypeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServiceTypeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServiceTypeRepository create(Ref ref) {
    return serviceTypeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceTypeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceTypeRepository>(value),
    );
  }
}

String _$serviceTypeRepositoryHash() =>
    r'ca4e4ae22e4e32c9376b5b141147e778b0a682d5';

@ProviderFor(firebaseRemoteConfig)
const firebaseRemoteConfigProvider = FirebaseRemoteConfigProvider._();

final class FirebaseRemoteConfigProvider
    extends
        $FunctionalProvider<
          FirebaseRemoteConfig,
          FirebaseRemoteConfig,
          FirebaseRemoteConfig
        >
    with $Provider<FirebaseRemoteConfig> {
  const FirebaseRemoteConfigProvider._()
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
const featureFlagServiceProvider = FeatureFlagServiceProvider._();

final class FeatureFlagServiceProvider
    extends
        $FunctionalProvider<
          FeatureFlagService,
          FeatureFlagService,
          FeatureFlagService
        >
    with $Provider<FeatureFlagService> {
  const FeatureFlagServiceProvider._()
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

/// Master switch for the paid tier. Every paywall/freemium decision reads this
/// one provider — don't call [FeatureFlagService.isEnabled] ad hoc in the UI.

@ProviderFor(isPaymentsEnabled)
const isPaymentsEnabledProvider = IsPaymentsEnabledProvider._();

/// Master switch for the paid tier. Every paywall/freemium decision reads this
/// one provider — don't call [FeatureFlagService.isEnabled] ad hoc in the UI.

final class IsPaymentsEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Master switch for the paid tier. Every paywall/freemium decision reads this
  /// one provider — don't call [FeatureFlagService.isEnabled] ad hoc in the UI.
  const IsPaymentsEnabledProvider._()
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
const appUpdateServiceProvider = AppUpdateServiceProvider._();

final class AppUpdateServiceProvider
    extends
        $FunctionalProvider<
          AppUpdateService,
          AppUpdateService,
          AppUpdateService
        >
    with $Provider<AppUpdateService> {
  const AppUpdateServiceProvider._()
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

String _$appUpdateServiceHash() => r'ada0d9c5b49d19f4445c71d58dd37e9588916b8b';

@ProviderFor(subscriptionService)
const subscriptionServiceProvider = SubscriptionServiceProvider._();

final class SubscriptionServiceProvider
    extends
        $FunctionalProvider<
          SubscriptionService,
          SubscriptionService,
          SubscriptionService
        >
    with $Provider<SubscriptionService> {
  const SubscriptionServiceProvider._()
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
const entitlementProvider = EntitlementProvider._();

final class EntitlementProvider
    extends
        $FunctionalProvider<
          AsyncValue<Entitlement>,
          Entitlement,
          Stream<Entitlement>
        >
    with $FutureModifier<Entitlement>, $StreamProvider<Entitlement> {
  const EntitlementProvider._()
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
const isPremiumProvider = IsPremiumProvider._();

final class IsPremiumProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsPremiumProvider._()
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

@ProviderFor(interstitialAdService)
const interstitialAdServiceProvider = InterstitialAdServiceProvider._();

final class InterstitialAdServiceProvider
    extends
        $FunctionalProvider<
          InterstitialAdService,
          InterstitialAdService,
          InterstitialAdService
        >
    with $Provider<InterstitialAdService> {
  const InterstitialAdServiceProvider._()
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
    r'9df4a1d763701c9f69064f8225f4f8bcfdaecc58';

@ProviderFor(creationAdCoordinator)
const creationAdCoordinatorProvider = CreationAdCoordinatorProvider._();

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
  const CreationAdCoordinatorProvider._()
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
    r'10af40c6ed1a2e9232fc3b9a2e744690358df149';

@ProviderFor(bannerAdPolicy)
const bannerAdPolicyProvider = BannerAdPolicyProvider._();

final class BannerAdPolicyProvider
    extends $FunctionalProvider<BannerAdPolicy, BannerAdPolicy, BannerAdPolicy>
    with $Provider<BannerAdPolicy> {
  const BannerAdPolicyProvider._()
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

String _$bannerAdPolicyHash() => r'f063b1a1a995c21303c1d27d56c2f67fc3ce26c6';

@ProviderFor(freemiumGuard)
const freemiumGuardProvider = FreemiumGuardProvider._();

final class FreemiumGuardProvider
    extends $FunctionalProvider<FreemiumGuard, FreemiumGuard, FreemiumGuard>
    with $Provider<FreemiumGuard> {
  const FreemiumGuardProvider._()
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
