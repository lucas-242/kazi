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

  /// Single defaults map for the whole app — Remote Config's `setDefaults`
  /// replaces the previous map wholesale, so every key must be declared here.
  /// Feature flags contribute their own keys straight from [FeatureFlag].
  static Map<String, dynamic> get defaults => {
    minRequiredVersion: '0.0.0',
    latestVersion: '0.0.0',
    interstitialAdFrequency: 3,
    bannerAdFrequency: 3,
    for (final flag in FeatureFlag.values) flag.key: flag.defaultValue,
  };
}
