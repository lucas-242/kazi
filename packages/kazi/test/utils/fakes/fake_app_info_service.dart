// `KaziInAppReviewService` is not re-exported from the kazi_core barrel, so it
// is imported from its own path.
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service.dart';

class FakeAppInfoService implements KaziAppInfoService {
  FakeAppInfoService([this.version = '1.0.0']);

  String version;

  @override
  Future<String> getVersion() async => version;
}

class FakeInAppReviewService implements KaziInAppReviewService {
  int requestCount = 0;

  @override
  Future<void> requestReview() async => requestCount++;
}
