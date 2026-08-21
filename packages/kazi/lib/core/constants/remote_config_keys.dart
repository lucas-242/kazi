import 'package:kazi/core/services/domain/feature_flag.dart';

abstract class RemoteConfigKeys {
  static const String minRequiredVersion = 'min_required_version';
  static const String latestVersion = 'latest_version';

  /// Number of creation actions between two interstitial ads shown to free
  /// users. Tunable remotely; falls back to a code default when unset/invalid.
  static const String interstitialAdFrequency = 'interstitial_ad_frequency';

  /// Number of list items between two banner ads shown to free users. Tunable
  /// remotely; falls back to a code default when unset/invalid.
  static const String bannerAdFrequency = 'banner_ad_frequency';

  /// Master switch for every analytics event, both sinks. Set to `false` to
  /// stop collection everywhere without shipping a release.
  static const String analyticsEnabled = 'analytics_enabled';

  /// Master switch for session replay. Independent of [analyticsEnabled]
  /// because replay is the expensive, most privacy-sensitive half: this is the
  /// one to reach for first, and it takes effect on the next app start.
  static const String replayEnabled = 'replay_enabled';

  /// Percentage (0–100) of sessions recorded for accounts younger than
  /// [replayNewUserDays]. Defaults to everything: the first week is where
  /// abandonment happens, and a sample of it answers nothing.
  static const String replaySampleNewUsers = 'replay_sample_new_users';

  /// Percentage (0–100) of sessions recorded for everyone else. Enough to spot
  /// a pattern, small enough not to dominate the replay quota.
  static const String replaySampleReturning = 'replay_sample_returning';

  /// Whether detected friction promotes a session to being recorded mid-flight,
  /// regardless of the sampling above.
  static const String replayOnFriction = 'replay_on_friction';

  /// Account age, in days, below which a user still counts as new for the
  /// sampling split.
  static const String replayNewUserDays = 'replay_new_user_days';

  /// Single defaults map for the whole app — Remote Config's `setDefaults`
  /// replaces the previous map wholesale, so every key must be declared here.
  /// Feature flags contribute their own keys straight from [FeatureFlag].
  static Map<String, dynamic> get defaults => {
    minRequiredVersion: '0.0.0',
    latestVersion: '0.0.0',
    interstitialAdFrequency: 3,
    bannerAdFrequency: 3,
    analyticsEnabled: true,
    replayEnabled: true,
    replaySampleNewUsers: 100,
    replaySampleReturning: 20,
    replayOnFriction: true,
    replayNewUserDays: 7,
    for (final flag in FeatureFlag.values) flag.key: flag.defaultValue,
  };
}
