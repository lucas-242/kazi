import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_manager.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';

class _InMemoryStorage implements KaziLocalStorageService {
  final Map<String, Object?> store = {};

  @override
  Future<void> write<T>(String key, T value) async => store[key] = value;

  @override
  Future<T?> read<T>(String key) async => store[key] as T?;

  @override
  Future<bool> containsKey(String key) async => store.containsKey(key);

  @override
  Future<void> remove(String key) async => store.remove(key);

  @override
  Future<void> clear() async => store.clear();
}

class _SpyReviewService implements KaziInAppReviewService {
  int requests = 0;

  @override
  Future<void> requestReview() async => requests++;
}

void main() {
  late _InMemoryStorage storage;
  late _SpyReviewService reviewService;
  late KaziInAppReviewManager manager;

  setUp(() {
    storage = _InMemoryStorage();
    reviewService = _SpyReviewService();
    manager = KaziInAppReviewManager(
      storage: storage,
      reviewService: reviewService,
    );
  });

  void seed({int? servicesCreated, int? daysSinceFirstLaunch}) {
    if (servicesCreated != null) {
      storage.store[KaziStorageKeys.servicesCreatedCount] = servicesCreated;
    }
    if (daysSinceFirstLaunch != null) {
      storage.store[KaziStorageKeys.firstAppLaunchDate] = DateTime.now()
          .subtract(Duration(days: daysSinceFirstLaunch))
          .toIso8601String();
    }
  }

  group('service count threshold', () {
    test('does not request a review before the 20th service', () async {
      seed(servicesCreated: 18, daysSinceFirstLaunch: 10);

      await manager.onServiceCreated();

      expect(storage.store[KaziStorageKeys.servicesCreatedCount], 19);
      expect(reviewService.requests, 0);
    });

    test('requests a review on the 20th service', () async {
      seed(servicesCreated: 19, daysSinceFirstLaunch: 10);

      await manager.onServiceCreated();

      expect(storage.store[KaziStorageKeys.servicesCreatedCount], 20);
      expect(reviewService.requests, 1);
      expect(storage.store[KaziStorageKeys.hasCompletedReview], isTrue);
    });
  });

  test('does not request before the account is 2 days old', () async {
    seed(servicesCreated: 19, daysSinceFirstLaunch: 1);

    await manager.onServiceCreated();

    expect(reviewService.requests, 0);
  });

  test('counts services but stays silent, then fires once eligible', () async {
    seed(daysSinceFirstLaunch: 10);

    for (var i = 0; i < 20; i++) {
      await manager.onServiceCreated();
    }

    expect(reviewService.requests, 1);
  });

  group('once completed', () {
    setUp(() {
      storage.store[KaziStorageKeys.hasCompletedReview] = true;
      seed(servicesCreated: 50, daysSinceFirstLaunch: 30);
    });

    test('never requests again from a service creation', () async {
      await manager.onServiceCreated();

      expect(reviewService.requests, 0);
      expect(storage.store[KaziStorageKeys.servicesCreatedCount], 50);
    });

    test('never requests again from an app start', () async {
      storage.store[KaziStorageKeys.lastReviewRequestDate] = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String();

      await manager.onAppStarted();

      expect(reviewService.requests, 0);
    });
  });

  test('records the first launch date once', () async {
    await manager.onAppStarted();
    final first = storage.store[KaziStorageKeys.firstAppLaunchDate];

    await manager.onAppStarted();

    expect(storage.store[KaziStorageKeys.firstAppLaunchDate], first);
  });

  test('an app start alone requests a review when every rule is met', () async {
    seed(servicesCreated: 20, daysSinceFirstLaunch: 10);

    await manager.onAppStarted();

    expect(reviewService.requests, 1);
  });
}
