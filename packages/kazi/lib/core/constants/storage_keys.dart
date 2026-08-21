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

  /// Uid of the account whose activation milestone has already been reported,
  /// so the count that decides it is queried once per user rather than on every
  /// service they ever create.
  static String firstServiceReportedFor = 'firstServiceReportedFor';

  /// Whether the user objected to usage analytics. Absent means "not
  /// objected" — the events run on legitimate interest, disclosed in the
  /// privacy policy, and this key records the opposition when it is exercised.
  static String analyticsOptOut = 'analyticsOptOut';

  /// Answer to the session-recording question: `'true'`, `'false'`, or absent
  /// when it has not been asked yet. Absent is **not** consent — the three
  /// states are distinct on purpose, so "not asked" can still be asked and
  /// "declined" is never re-read as a default.
  static String sessionReplayConsent = 'sessionReplayConsent';

  /// App version the "what changed" screen was last shown for. Stored as the
  /// version rather than a bool so a later release can announce itself, and
  /// read as "not this version" so a corrupt value simply shows it once more.
  static String whatsNewSeenVersion = 'whatsNewSeenVersion';
}
