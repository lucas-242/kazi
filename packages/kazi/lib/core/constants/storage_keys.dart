abstract class StorageKeys {
  /// Key to identify if it is necessary to display the onboarding
  static String showOnboarding = 'showOnboarding';

  /// Key to identify the user language code selected by the user
  static String userLanguageCode = 'userLanguageCode';

  /// ISO date of the last time the optional-update dialog was shown, used to
  /// throttle it to at most once per day.
  static String lastOptionalUpdatePromptDate = 'lastOptionalUpdatePromptDate';
}
