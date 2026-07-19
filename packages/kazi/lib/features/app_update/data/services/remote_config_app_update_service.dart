import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/utils/version_comparator.dart';
import 'package:kazi/features/app_update/domain/models/app_update_info.dart';
import 'package:kazi/features/app_update/domain/services/app_update_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

final class RemoteConfigAppUpdateService implements AppUpdateService {
  RemoteConfigAppUpdateService(
    this._remoteConfig,
    this._appInfoService,
    this._crashlyticsService,
  );

  final FirebaseRemoteConfig _remoteConfig;
  final KaziAppInfoService _appInfoService;
  final CrashlyticsService _crashlyticsService;

  @override
  Future<AppUpdateInfo> checkForUpdate() async {
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
      await _remoteConfig.fetchAndActivate();

      final currentVersion = await _appInfoService.getVersion();
      final minRequired = _remoteConfig.getString(
        RemoteConfigKeys.minRequiredVersion,
      );
      final latest = _remoteConfig.getString(RemoteConfigKeys.latestVersion);

      return AppUpdateInfo(
        status: _resolveStatus(
          current: currentVersion,
          minRequired: minRequired,
          latest: latest,
        ),
        latestVersion: latest,
        storeUrl: _storeUrl(),
      );
    } catch (exception, stackTrace) {
      // Fail-open: never lock the user out because of a fetch/parse failure.
      _crashlyticsService.log(exception, stackTrace);
      return const AppUpdateInfo.upToDate();
    }
  }

  AppUpdateStatus _resolveStatus({
    required String current,
    required String minRequired,
    required String latest,
  }) {
    if (VersionComparator.compareVersions(current, minRequired) < 0) {
      return AppUpdateStatus.mandatory;
    }
    if (VersionComparator.compareVersions(current, latest) < 0) {
      return AppUpdateStatus.optional;
    }
    return AppUpdateStatus.upToDate;
  }

  String _storeUrl() => Platform.isIOS
      ? _remoteConfig.getString(Environment.iosStoreUrl)
      : _remoteConfig.getString(Environment.androidStoreUrl);
}
