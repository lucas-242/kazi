import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';

/// Decides whether this session is recorded: everything from an account younger
/// than [newUserDays], a slice of everyone else, and any session that shows
/// friction.
///
/// Every number comes from Remote Config, so the volume can be cut to zero
/// without a release. Kept in one object, like `BannerAdPolicy`, so the rule can
/// be stated and turned off in one place.
class SessionReplayPolicy {
  SessionReplayPolicy({required FirebaseRemoteConfig remoteConfig})
    : isEnabled = _bool(remoteConfig, RemoteConfigKeys.replayEnabled),
      recordsOnFriction = _bool(remoteConfig, RemoteConfigKeys.replayOnFriction),
      newUserSamplePercent = _percent(
        remoteConfig,
        RemoteConfigKeys.replaySampleNewUsers,
        _defaultNewUserPercent,
      ),
      returningSamplePercent = _percent(
        remoteConfig,
        RemoteConfigKeys.replaySampleReturning,
        _defaultReturningPercent,
      ),
      newUserDays = _days(remoteConfig);

  /// Used by tests and by any path where Remote Config has not resolved.
  const SessionReplayPolicy.raw({
    required this.isEnabled,
    required this.recordsOnFriction,
    required this.newUserSamplePercent,
    required this.returningSamplePercent,
    required this.newUserDays,
  });

  static const int _defaultNewUserPercent = 100;
  static const int _defaultReturningPercent = 20;
  static const int _defaultNewUserDays = 7;

  final bool isEnabled;
  final bool recordsOnFriction;
  final int newUserSamplePercent;
  final int returningSamplePercent;
  final int newUserDays;

  /// A null age counts as new: over-recording a few sessions is the cheaper
  /// mistake than missing a first week.
  bool isNewUser(int? accountAgeDays) =>
      accountAgeDays == null || accountAgeDays < newUserDays;

  /// [roll] is drawn once per session by the caller, in `[0, 1)`, which keeps
  /// this pure and the sampling testable at its edges.
  bool shouldRecordAtStart({required bool isNewUser, required double roll}) {
    if (!isEnabled) return false;
    final percent = isNewUser ? newUserSamplePercent : returningSamplePercent;
    if (percent <= 0) return false;
    if (percent >= 100) return true;
    return roll * 100 < percent;
  }

  /// Whether friction should promote a session that was not being recorded.
  bool shouldRecordOnFriction() => isEnabled && recordsOnFriction;

  /// `valueStatic` means Remote Config knows nothing about the key, and
  /// `getBool` would answer `false` for it — letting a failed fetch masquerade
  /// as someone pulling the switch. These are operational switches, not
  /// consent, so an unknown key resolves to "on".
  static bool _bool(FirebaseRemoteConfig remoteConfig, String key) {
    final value = remoteConfig.getValue(key);
    if (value.source == ValueSource.valueStatic) return true;
    return value.asBool();
  }

  /// Falls back when the key is unknown or was set outside 0–100 in the console.
  static int _percent(
    FirebaseRemoteConfig remoteConfig,
    String key,
    int fallback,
  ) {
    final value = remoteConfig.getValue(key);
    if (value.source == ValueSource.valueStatic) return fallback;
    final remote = value.asInt();
    return remote >= 0 && remote <= 100 ? remote : fallback;
  }

  static int _days(FirebaseRemoteConfig remoteConfig) {
    final remote = remoteConfig.getInt(RemoteConfigKeys.replayNewUserDays);
    return remote > 0 ? remote : _defaultNewUserDays;
  }
}
