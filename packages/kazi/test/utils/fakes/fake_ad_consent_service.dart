import 'package:kazi/core/services/domain/ad_consent_service.dart';

class FakeAdConsentService implements AdConsentService {
  FakeAdConsentService({
    this.canRequest = true,
    this.isPrivacyOptionsRequiredValue = false,
    this.gatherError,
  });

  bool canRequest;
  bool isPrivacyOptionsRequiredValue;
  Object? gatherError;

  int gatherCount = 0;
  int privacyOptionsCount = 0;

  @override
  Future<void> gather() async {
    gatherCount++;
    final error = gatherError;
    if (error != null) throw error;
  }

  @override
  Future<bool> canRequestAds() async => canRequest;

  @override
  Future<bool> isPrivacyOptionsRequired() async =>
      isPrivacyOptionsRequiredValue;

  @override
  Future<void> showPrivacyOptions() async => privacyOptionsCount++;
}
