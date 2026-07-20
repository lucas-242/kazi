/// Local storage keys used across kazi_core shared services.
abstract class KaziStorageKeys {
  /// ISO date of the first time the app was launched, used to gate the
  /// in-app review request.
  static const String firstAppLaunchDate = 'first_app_launch_date';

  /// Count of services created by the user, used to gate the in-app review
  /// request.
  static const String servicesCreatedCount = 'services_created_count';

  /// Flag that marks whether the user already completed a review, stopping
  /// further review requests.
  static const String hasCompletedReview = 'has_completed_review';

  /// ISO date of the last time a review was requested, used to throttle
  /// consecutive requests.
  static const String lastReviewRequestDate = 'last_review_request_date';
}
