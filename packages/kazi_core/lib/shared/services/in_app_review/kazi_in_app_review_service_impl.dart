import 'package:flutter/foundation.dart' show debugPrint;
import 'package:in_app_review/in_app_review.dart';

import 'kazi_in_app_review_service.dart';

final class KaziInAppReviewServiceImpl implements KaziInAppReviewService {
  KaziInAppReviewServiceImpl({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  @override
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint('Error requesting review: $e');
    }
  }
}
