abstract class RemoteConfigKeys {
  static const String minRequiredVersion = 'min_required_version';
  static const String latestVersion = 'latest_version';

  /// Number of creation actions between two interstitial ads shown to free
  /// users. Tunable remotely; falls back to a code default when unset/invalid.
  static const String interstitialAdFrequency = 'interstitial_ad_frequency';

  /// Number of list items between two banner ads shown to free users. Tunable
  /// remotely; falls back to a code default when unset/invalid.
  static const String bannerAdFrequency = 'banner_ad_frequency';

  static Map<String, dynamic> get defaults => {
    minRequiredVersion: '0.0.0',
    latestVersion: '0.0.0',
    interstitialAdFrequency: 3,
    bannerAdFrequency: 3,
  };
}
