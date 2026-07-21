import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';

class BannerAdPolicy {
  BannerAdPolicy({
    required bool isPremium,
    required FirebaseRemoteConfig remoteConfig,
  }) : _isPremium = isPremium,
       frequency = _resolveFrequency(remoteConfig);

  static const int _defaultFrequency = 3;

  final bool _isPremium;

  /// Number of list items between two banners shown to free users.
  final int frequency;

  /// Whether a banner should be inserted before the list item at [index].
  /// Premium users never see one; index 0 never gets one.
  bool shouldShowAt(int index) =>
      !_isPremium && index != 0 && index % frequency == 0;

  static int _resolveFrequency(FirebaseRemoteConfig remoteConfig) {
    final remote = remoteConfig.getInt(RemoteConfigKeys.bannerAdFrequency);
    return remote > 0 ? remote : _defaultFrequency;
  }
}
