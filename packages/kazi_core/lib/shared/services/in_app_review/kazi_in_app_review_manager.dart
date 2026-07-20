import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';
import 'package:kazi_core/shared/utils/log_utils.dart';

class KaziInAppReviewManager {
  KaziInAppReviewManager({
    required KaziLocalStorageService storage,
    required KaziInAppReviewService reviewService,
  })  : _storage = storage,
        _reviewService = reviewService;

  static const int _minDaysSinceFirstLaunch = 2;
  static const int _minServicesCreated = 5;
  static const int _daysBetweenReviewRequests = 2;

  final KaziLocalStorageService _storage;
  final KaziInAppReviewService _reviewService;

  /// Called whenever a service is created to count services
  Future<void> onAppStarted() async {
    try {
      await _onAppLaunch();
      await _maybeShowReview();
    } catch (e) {
      Log.error('Error to handle app review during app started: $e');
    }
  }

  /// Register first app lauch date
  Future<void> _onAppLaunch() async {
    if (await _hasCompletedReview()) return;

    if (await _storage.containsKey(KaziStorageKeys.firstAppLaunchDate)) return;

    await _storage.write(
      KaziStorageKeys.firstAppLaunchDate,
      DateTime.now().toIso8601String(),
    );
  }

  Future<bool> _hasCompletedReview() async =>
      await _storage.read<bool>(KaziStorageKeys.hasCompletedReview) ?? false;

  Future<void> _maybeShowReview() async {
    if (!await _shouldShowReview()) return;

    await _storage.write<String>(
      KaziStorageKeys.lastReviewRequestDate,
      DateTime.now().toIso8601String(),
    );
    await _reviewService.requestReview();
    await _onReviewCompleted();
  }

  Future<bool> _shouldShowReview() async {
    final firstLaunchDate = await _getFirstLaunchDate();
    final servicesCount = await _getServicesCreatedCount();
    final daysSinceFirstLaunch =
        DateTime.now().difference(firstLaunchDate).inDays;

    // Verify the number of days since the first launch
    if (daysSinceFirstLaunch < _minDaysSinceFirstLaunch) return false;

    // Verify the number of services created
    if (servicesCount < _minServicesCreated) return false;

    final lastRequestDate = await _getLastReviewRequestDate();
    if (lastRequestDate != null) {
      final daysSinceLastRequest =
          DateTime.now().difference(lastRequestDate).inDays;
      if (daysSinceLastRequest < _daysBetweenReviewRequests) {
        return false;
      }
    }
    return true;
  }

  Future<DateTime> _getFirstLaunchDate() async {
    final dateString = await _storage.read<String>(KaziStorageKeys.firstAppLaunchDate);
    return dateString != null ? DateTime.parse(dateString) : DateTime.now();
  }

  Future<int> _getServicesCreatedCount() async =>
      await _storage.read<int>(KaziStorageKeys.servicesCreatedCount) ?? 0;

  Future<DateTime?> _getLastReviewRequestDate() async {
    final dateString = await _storage.read<String>(KaziStorageKeys.lastReviewRequestDate);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  Future<void> _onReviewCompleted() async =>
      _storage.write<bool>(KaziStorageKeys.hasCompletedReview, true);

  /// Called whenever a service is created to count services
  Future<void> onServiceCreated() async {
    try {
      if (await _hasCompletedReview()) {
        return;
      }
      final count = await _getServicesCreatedCount();
      await _storage.write<int>(KaziStorageKeys.servicesCreatedCount, count + 1);
      await _maybeShowReview();
    } catch (e) {
      Log.error('Error to handle app review during service creation: $e');
    }
  }
}
