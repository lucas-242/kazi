import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:kazi/core/services/data/banner_ad_policy.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'fake_creation_ad_coordinator.dart';
import 'fake_subscription_service.dart';
import 'fakes/fake_analytics_service.dart';
import 'fakes/fake_app_info_service.dart';
import 'fakes/fake_app_update_service.dart';
import 'fakes/fake_auth_service.dart';
import 'fakes/fake_crashlytics_service.dart';
import 'fakes/fake_feature_flag_service.dart';
import 'fakes/fake_interstitial_ad_service.dart';
import 'fakes/fake_local_storage.dart';
import 'fakes/fake_remote_currency_store.dart';
import 'fakes/fake_time_service.dart';
import 'shared_mocks.dart';

/// The fakes backing one test's provider overrides, kept addressable so a test
/// can assert against them (`fakes.analytics.events`, `fakes.firestore`, …).
class TestFakes {
  TestFakes({
    FakeAuthService? auth,
    FakeFirebaseFirestore? firestore,
    bool isPremium = true,
    DateTime? now,
  }) : auth = auth ?? FakeAuthService(),
       firestore = firestore ?? FakeFirebaseFirestore(),
       time = FakeTimeService(now),
       subscription = FakeSubscriptionService(
         entitlement: isPremium
             ? const Entitlement(
                 isPremium: true,
                 isInGracePeriod: false,
                 willRenew: true,
                 isTrial: false,
                 hasPaidBefore: true,
               )
             : const Entitlement(
                 isPremium: false,
                 isInGracePeriod: false,
                 willRenew: false,
                 isTrial: false,
                 hasPaidBefore: false,
               ),
       ),
       _isPremium = isPremium;

  final FakeAuthService auth;
  final FakeFirebaseFirestore firestore;
  final FakeTimeService time;
  final FakeSubscriptionService subscription;
  final bool _isPremium;

  final crashlytics = FakeCrashlyticsService();
  final analytics = FakeAnalyticsService();
  final featureFlags = FakeFeatureFlagService();
  final appUpdate = FakeAppUpdateService();
  final storage = FakeLocalStorage();
  final interstitialAds = FakeInterstitialAdService();
  final appInfo = FakeAppInfoService();
  final inAppReview = FakeInAppReviewService();
  final remoteCurrencyStore = FakeRemoteCurrencyStore();
  final creationAds = FakeCreationAdCoordinator();
  final remoteConfig = stubRemoteConfig();

  /// Every app-level dependency that reaches outside the process, replaced.
  ///
  /// Three of these are not optional even for a screen that has nothing to do
  /// with them: `subscriptionService` and `interstitialAdService` read
  /// `Environment.instance` when constructed, and `Flavor.fromString('')!`
  /// throws under `flutter test`. `bannerAdPolicy` is the third — it decides
  /// whether `AdBlock` is built, and `AdBlock` reads the environment too.
  List<Override> get overrides => [
    firebaseFirestoreProvider.overrideWithValue(firestore),
    crashlyticsServiceProvider.overrideWithValue(crashlytics),
    analyticsServiceProvider.overrideWithValue(analytics),
    authServiceProvider.overrideWithValue(auth),
    timeServiceProvider.overrideWithValue(time),
    firebaseRemoteConfigProvider.overrideWithValue(remoteConfig),
    featureFlagServiceProvider.overrideWithValue(featureFlags),
    appUpdateServiceProvider.overrideWithValue(appUpdate),
    subscriptionServiceProvider.overrideWithValue(subscription),
    isPremiumProvider.overrideWithValue(_isPremium),
    interstitialAdServiceProvider.overrideWithValue(interstitialAds),
    creationAdCoordinatorProvider.overrideWith((ref) async => creationAds),
    bannerAdPolicyProvider.overrideWithValue(
      BannerAdPolicy(isPremium: true, remoteConfig: remoteConfig),
    ),
    // `freemiumGuardProvider` is deliberately NOT overridden: the real guard
    // resolves from the providers above, so it counts the services and clients
    // actually seeded into the fake Firestore. Overriding it with fixed counts
    // would make every gate answer the same regardless of the data under test.
    // kazi_core
    localStorageProvider.overrideWith((ref) async => storage),
    kaziAppInfoServiceProvider.overrideWithValue(appInfo),
    inAppReviewServiceProvider.overrideWithValue(inAppReview),
    kaziRemoteCurrencyStoreProvider.overrideWithValue(remoteCurrencyStore),
    exchangeRateRepositoryProvider.overrideWithValue(
      MockExchangeRateRepository(),
    ),
    exchangeRateHistoryRepositoryProvider.overrideWithValue(
      InMemoryExchangeRateHistoryRepository(),
    ),
  ];

  void dispose() => auth.dispose();
}
