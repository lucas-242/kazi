abstract class StorageKeys {
  /// Key to identify if it is necessary to display the onboarding
  static String showOnboarding = 'showOnboarding';

  /// Key to identify the user language code selected by the user
  static String userLanguageCode = 'userLanguageCode';

  /// ISO date of the last time the optional-update dialog was shown, used to
  /// throttle it to at most once per day.
  static String lastOptionalUpdatePromptDate = 'lastOptionalUpdatePromptDate';

  /// Count of creation actions (client / service type / service) since the last
  /// interstitial ad was shown, used to gate its frequency for free users.
  static String interstitialActionCount = 'interstitialActionCount';

  /// App version the "what changed" screen was last shown for. Stored as the
  /// version rather than a bool so a later release can announce itself, and
  /// read as "not this version" so a corrupt value simply shows it once more.
  static String whatsNewSeenVersion = 'whatsNewSeenVersion';
}
