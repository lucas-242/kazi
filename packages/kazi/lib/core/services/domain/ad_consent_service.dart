/// The ad-consent questions Google's User Messaging Platform owns: GDPR and
/// US-state consent and, on iOS, the explainer that precedes the ATT prompt.
abstract interface class AdConsentService {
  /// Refreshes the consent requirements for this device and presents the
  /// consent form when one is owed. Completes once it is answered or when
  /// nothing was owed.
  Future<void> gather();

  /// Whether ads may be requested — true unless a consent that is required has
  /// not been obtained. Answers from the last status persisted on the device.
  Future<bool> canRequestAds();

  /// Whether the app must offer a way back into the consent choices.
  Future<bool> isPrivacyOptionsRequired();

  Future<void> showPrivacyOptions();
}
