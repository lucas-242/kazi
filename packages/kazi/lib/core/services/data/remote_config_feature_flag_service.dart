import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/domain/feature_flag.dart';
import 'package:kazi/core/services/domain/feature_flag_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Firebase Remote Config backed [FeatureFlagService].
///
/// [init] publishes [RemoteConfigKeys.defaults] before fetching, so a flag read
/// is meaningful even when the device is offline. It is fail-safe: a fetch
/// error is logged and leaves the code defaults in place instead of blocking
/// startup or silently killing a feature.
final class RemoteConfigFeatureFlagService implements FeatureFlagService {
  RemoteConfigFeatureFlagService(this._remoteConfig, this._crashlyticsService);

  final FirebaseRemoteConfig _remoteConfig;
  final CrashlyticsService _crashlyticsService;

  @override
  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.setDefaults(RemoteConfigKeys.defaults);
      final activated = await _remoteConfig.fetchAndActivate();
      _logResolvedFlags(activated: activated);
    } catch (exception, stackTrace) {
      _crashlyticsService.log(exception, stackTrace);
    }
  }

  /// Debug-only trace of where each flag's value actually came from. A flag that
  /// reads `valueDefault` is *not* coming from the console — either the
  /// parameter is unpublished, set to "use in-app default", or this build points
  /// at a different Firebase project.
  void _logResolvedFlags({required bool activated}) {
    if (!kDebugMode) {
      return;
    }
    Log.flow(
      'RemoteConfig: activated=$activated '
      'status=${_remoteConfig.lastFetchStatus.name} '
      'at=${_remoteConfig.lastFetchTime}',
    );
    for (final flag in FeatureFlag.values) {
      final value = _remoteConfig.getValue(flag.key);
      Log.flow(
        'Flag ${flag.key}: ${isEnabled(flag)} '
        '(source=${value.source.name}, raw="${value.asString()}")',
      );
    }
  }

  @override
  bool isEnabled(FeatureFlag flag) {
    final value = _remoteConfig.getValue(flag.key);
    // `valueStatic` means Remote Config knows nothing about the key — neither a
    // published default nor a fetched value — and would answer `false` for any
    // flag. Fall back to the binary's own default instead.
    if (value.source == ValueSource.valueStatic) {
      return flag.defaultValue;
    }
    return value.asBool();
  }
}
