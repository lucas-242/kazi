import 'package:kazi_core/shared/constants/kazi_storage_keys.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';
import 'package:kazi_core/shared/utils/log_utils.dart';

/// Decides when to ask for a store review. The rules, and why each threshold is
/// what it is, are in README.md.
class KaziInAppReviewManager {
  KaziInAppReviewManager({
    required KaziLocalStorageService storage,
    required KaziInAppReviewService reviewService,
  })  : _storage = storage,
        _reviewService = reviewService;

  static const int _minDaysSinceFirstLaunch = 2;
  static const int _minServicesCreated = 20;
  static const int _daysBetweenReviewRequests = 2;

  final KaziLocalStorageService _storage;
  final KaziInAppReviewService _reviewService;

  Future<void> onAppStarted() async {
    try {
      await _registerFirstLaunch();
      await _maybeShowReview();
    } catch (e) {
      Log.error('Error to handle app review during app started: $e');
    }
  }

  Future<void> onServiceCreated() async {
    try {
      if (await _hasCompletedReview()) return;

      final count = await _getServicesCreatedCount();
      await _storage.write<int>(KaziStorageKeys.servicesCreatedCount, count + 1);
      await _maybeShowReview();
    } catch (e) {
      Log.error('Error to handle app review during service creation: $e');
    }
  }

  Future<void> _registerFirstLaunch() async {
    if (await _hasCompletedReview()) return;
    if (await _storage.containsKey(KaziStorageKeys.firstAppLaunchDate)) return;

    await _storage.write(
      KaziStorageKeys.firstAppLaunchDate,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _maybeShowReview() async {
    if (!await _shouldShowReview()) return;

    await _storage.write<String>(
      KaziStorageKeys.lastReviewRequestDate,
      DateTime.now().toIso8601String(),
    );
    await _reviewService.requestReview();
    await _storage.write<bool>(KaziStorageKeys.hasCompletedReview, true);
  }

  Future<bool> _shouldShowReview() async {
    // Checked here rather than only in the callers: without it the app-start
    // path re-prompts every `_daysBetweenReviewRequests` days forever.
    if (await _hasCompletedReview()) return false;

    final firstLaunchDate = await _getFirstLaunchDate();
    final daysSinceFirstLaunch =
        DateTime.now().difference(firstLaunchDate).inDays;
    if (daysSinceFirstLaunch < _minDaysSinceFirstLaunch) return false;

    if (await _getServicesCreatedCount() < _minServicesCreated) return false;

    final lastRequestDate = await _getLastReviewRequestDate();
    if (lastRequestDate != null) {
      final daysSinceLastRequest =
          DateTime.now().difference(lastRequestDate).inDays;
      if (daysSinceLastRequest < _daysBetweenReviewRequests) return false;
    }

    return true;
  }

  Future<bool> _hasCompletedReview() async =>
      await _storage.read<bool>(KaziStorageKeys.hasCompletedReview) ?? false;

  Future<DateTime> _getFirstLaunchDate() async {
    final dateString =
        await _storage.read<String>(KaziStorageKeys.firstAppLaunchDate);
    return dateString != null ? DateTime.parse(dateString) : DateTime.now();
  }

  Future<int> _getServicesCreatedCount() async =>
      await _storage.read<int>(KaziStorageKeys.servicesCreatedCount) ?? 0;

  Future<DateTime?> _getLastReviewRequestDate() async {
    final dateString =
        await _storage.read<String>(KaziStorageKeys.lastReviewRequestDate);
    return dateString != null ? DateTime.parse(dateString) : null;
  }
}
