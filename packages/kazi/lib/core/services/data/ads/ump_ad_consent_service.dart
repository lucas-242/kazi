import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/core/services/domain/ad_consent_service.dart';

final class UmpAdConsentService implements AdConsentService {
  /// Bounds only the network round trip, never the form: the bootstrap awaits
  /// this on the splash, and the form waits for the person, not the network.
  static const _updateTimeout = Duration(seconds: 10);

  @override
  Future<void> gather() async {
    await _requestConsentInfoUpdate().timeout(_updateTimeout);

    final dismissed = Completer<FormError?>();
    await ConsentForm.loadAndShowConsentFormIfRequired(dismissed.complete);
    _throwIfError(await dismissed.future);
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<bool> isPrivacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  @override
  Future<void> showPrivacyOptions() async {
    final dismissed = Completer<FormError?>();
    await ConsentForm.showPrivacyOptionsForm(dismissed.complete);
    _throwIfError(await dismissed.future);
  }

  Future<void> _requestConsentInfoUpdate() {
    final updated = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      updated.complete,
      (error) => updated.completeError(_describe(error)),
    );
    return updated.future;
  }

  void _throwIfError(FormError? error) {
    if (error != null) throw _describe(error);
  }

  Exception _describe(FormError error) =>
      Exception('UMP error ${error.errorCode}: ${error.message}');
}
