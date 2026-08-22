import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/app_update/data/services/remote_config_app_update_service.dart';
import 'package:kazi/features/app_update/domain/models/app_update_info.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'remote_config_app_update_service_test.mocks.dart';

@GenerateMocks([FirebaseRemoteConfig, KaziAppInfoService, CrashlyticsService])
void main() {
  late MockFirebaseRemoteConfig remoteConfig;
  late MockKaziAppInfoService appInfoService;
  late MockCrashlyticsService crashlyticsService;
  late RemoteConfigAppUpdateService service;

  const currentVersion = '1.2.0';

  void stubVersions({required String minRequired, required String latest}) {
    when(
      remoteConfig.getString(RemoteConfigKeys.minRequiredVersion),
    ).thenReturn(minRequired);
    when(
      remoteConfig.getString(RemoteConfigKeys.latestVersion),
    ).thenReturn(latest);
    when(
      remoteConfig.getString(Environment.androidStoreUrl),
    ).thenReturn('https://store/android');
    when(
      remoteConfig.getString(Environment.iosStoreUrl),
    ).thenReturn('https://store/ios');
  }

  setUp(() {
    remoteConfig = MockFirebaseRemoteConfig();
    appInfoService = MockKaziAppInfoService();
    crashlyticsService = MockCrashlyticsService();
    service = RemoteConfigAppUpdateService(
      remoteConfig,
      appInfoService,
      crashlyticsService,
    );

    when(
      remoteConfig.setConfigSettings(any),
    ).thenAnswer((_) => Future<void>.value());
    when(remoteConfig.setDefaults(any)).thenAnswer((_) => Future<void>.value());
    when(remoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
    when(appInfoService.getVersion()).thenAnswer((_) async => currentVersion);
  });

  test('returns upToDate when current version meets the latest', () async {
    stubVersions(minRequired: '1.0.0', latest: '1.2.0');

    final info = await service.checkForUpdate();

    expect(info.status, AppUpdateStatus.upToDate);
  });

  test('returns optional when a newer version is available', () async {
    stubVersions(minRequired: '1.0.0', latest: '1.4.0');

    final info = await service.checkForUpdate();

    expect(info.status, AppUpdateStatus.optional);
    expect(info.latestVersion, '1.4.0');
  });

  test('returns mandatory when below the minimum required', () async {
    stubVersions(minRequired: '1.3.0', latest: '1.4.0');

    final info = await service.checkForUpdate();

    expect(info.status, AppUpdateStatus.mandatory);
  });

  test('fail-open: returns upToDate and logs when fetch throws', () async {
    when(remoteConfig.fetchAndActivate()).thenThrow(Exception('offline'));

    final info = await service.checkForUpdate();

    expect(info.status, AppUpdateStatus.upToDate);
    verify(crashlyticsService.log(any, any)).called(1);
  });
}
