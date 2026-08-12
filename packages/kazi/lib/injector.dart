import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:kazi/core/currency/firebase_exchange_rate_history_repository.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/services/data/admob_interstitial_ad_service.dart';
import 'package:kazi/core/services/data/banner_ad_policy.dart';
import 'package:kazi/core/services/data/creation_ad_coordinator.dart';
import 'package:kazi/core/services/data/firebase_analytics_service.dart';
import 'package:kazi/core/services/data/firebase_crashlytics_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/data/remote_config_feature_flag_service.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/domain/feature_flag.dart';
import 'package:kazi/core/services/domain/feature_flag_service.dart';
import 'package:kazi/core/services/domain/interstitial_ad_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/app_update/data/services/remote_config_app_update_service.dart';
import 'package:kazi/features/app_update/domain/services/app_update_service.dart';
import 'package:kazi/features/auth/data/services/firebase_auth_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/data/repositories/firebase_clients_repository.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/data/repositories/firebase_service_type_repository.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/features/settings/data/repositories/firebase_currency_migration_repository.dart';
import 'package:kazi/features/settings/data/repositories/firebase_user_settings_repository.dart';
import 'package:kazi/features/settings/data/user_document_currency_store.dart';
import 'package:kazi/features/settings/domain/repositories/currency_migration_repository.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi/features/subscription/data/services/revenue_cat_subscription_service.dart';
import 'package:kazi/features/subscription/domain/freemium_guard.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/domain/services/subscription_service.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository;

part 'injector.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
CrashlyticsService crashlyticsService(Ref ref) =>
    FirebaseCrashlyticsService(FirebaseCrashlytics.instance);

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => FirebaseAnalyticsService(
  FirebaseAnalytics.instance,
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
TimeService timeService(Ref ref) => LocalTimeService();

@Riverpod()
ServicesService servicesService(Ref ref) =>
    LocalServicesService(ref.watch(timeServiceProvider));

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => FirebaseAuthService(
  crashlyticsService: ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
ServicesRepository servicesRepository(Ref ref) => FirebaseServicesRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
ClientsRepository clientsRepository(Ref ref) => FirebaseClientsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
ServiceTypeRepository serviceTypeRepository(Ref ref) =>
    FirebaseServiceTypeRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(crashlyticsServiceProvider),
    );

@Riverpod()
UserSettingsRepository userSettingsRepository(Ref ref) =>
    FirebaseUserSettingsRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(crashlyticsServiceProvider),
    );

@Riverpod()
CurrencyMigrationRepository currencyMigrationRepository(Ref ref) =>
    FirebaseCurrencyMigrationRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(crashlyticsServiceProvider),
    );

@Riverpod()
KaziRemoteCurrencyStore appRemoteCurrencyStore(Ref ref) =>
    UserDocumentCurrencyStore(
      repository: ref.watch(userSettingsRepositoryProvider),
      authService: ref.watch(authServiceProvider),
    );

@Riverpod()
ExchangeRateHistoryRepository appExchangeRateHistoryRepository(Ref ref) =>
    FirebaseExchangeRateHistoryRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) =>
    FirebaseRemoteConfig.instance;

@Riverpod(keepAlive: true)
FeatureFlagService featureFlagService(Ref ref) =>
    RemoteConfigFeatureFlagService(
      ref.watch(firebaseRemoteConfigProvider),
      ref.watch(crashlyticsServiceProvider),
    );

@Riverpod(keepAlive: true)
bool isPaymentsEnabled(Ref ref) =>
    ref.watch(featureFlagServiceProvider).isEnabled(FeatureFlag.payments);

@Riverpod()
AppUpdateService appUpdateService(Ref ref) => RemoteConfigAppUpdateService(
  ref.watch(firebaseRemoteConfigProvider),
  ref.watch(kaziAppInfoServiceProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(Ref ref) =>
    RevenueCatSubscriptionService(Environment.instance.revenueCatApiKey);

@Riverpod(keepAlive: true)
Stream<Entitlement> entitlement(Ref ref) =>
    ref.watch(subscriptionServiceProvider).changes();

@Riverpod(keepAlive: true)
bool isPremium(Ref ref) =>
    ref.watch(entitlementProvider).asData?.value.isPremium ?? false;

@Riverpod(keepAlive: true)
InterstitialAdService interstitialAdService(Ref ref) {
  final service = AdMobInterstitialAdService(
    Environment.instance.adKeyServiceCreate,
  );
  service.preload();
  return service;
}

@Riverpod(keepAlive: true)
Future<CreationAdCoordinator> creationAdCoordinator(Ref ref) async =>
    CreationAdCoordinator(
      adService: ref.watch(interstitialAdServiceProvider),
      storage: await ref.watch(localStorageProvider.future),
      remoteConfig: ref.watch(firebaseRemoteConfigProvider),
      isPremium: () => ref.read(isPremiumProvider),
    );

@Riverpod(keepAlive: true)
BannerAdPolicy bannerAdPolicy(Ref ref) => BannerAdPolicy(
  isPremium: ref.watch(isPremiumProvider),
  remoteConfig: ref.watch(firebaseRemoteConfigProvider),
);

@Riverpod()
FreemiumGuard freemiumGuard(Ref ref) => FreemiumGuard(
  subscriptionService: ref.watch(subscriptionServiceProvider),
  servicesRepository: ref.watch(servicesRepositoryProvider),
  clientsRepository: ref.watch(clientsRepositoryProvider),
  timeService: ref.watch(timeServiceProvider),
  isPaymentsEnabled: ref.watch(isPaymentsEnabledProvider),
);
