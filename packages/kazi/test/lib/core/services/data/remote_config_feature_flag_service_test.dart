import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';
import 'package:kazi/core/services/data/remote_config_feature_flag_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/domain/feature_flag.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'remote_config_feature_flag_service_test.mocks.dart';

@GenerateMocks([FirebaseRemoteConfig, CrashlyticsService, RemoteConfigValue])
void main() {
  late MockFirebaseRemoteConfig remoteConfig;
  late MockCrashlyticsService crashlyticsService;
  late RemoteConfigFeatureFlagService service;

  void stubFlag(FeatureFlag flag, {required bool value, ValueSource? source}) {
    final remoteValue = MockRemoteConfigValue();
    when(remoteValue.source).thenReturn(source ?? ValueSource.valueRemote);
    when(remoteValue.asBool()).thenReturn(value);
    when(remoteConfig.getValue(flag.key)).thenReturn(remoteValue);
  }

  setUp(() {
    remoteConfig = MockFirebaseRemoteConfig();
    crashlyticsService = MockCrashlyticsService();
    service = RemoteConfigFeatureFlagService(remoteConfig, crashlyticsService);

    when(
      remoteConfig.setConfigSettings(any),
    ).thenAnswer((_) => Future<void>.value());
    when(remoteConfig.setDefaults(any)).thenAnswer((_) => Future<void>.value());
    when(remoteConfig.fetchAndActivate()).thenAnswer((_) async => true);
  });

  group('init', () {
    test('publishes the shared defaults before fetching', () async {
      await service.init();

      verify(remoteConfig.setDefaults(RemoteConfigKeys.defaults)).called(1);
      verify(remoteConfig.fetchAndActivate()).called(1);
    });

    test('the shared defaults carry every feature flag', () {
      for (final flag in FeatureFlag.values) {
        expect(RemoteConfigKeys.defaults[flag.key], flag.defaultValue);
      }
    });

    test('logs and keeps the code defaults when the fetch fails', () async {
      when(remoteConfig.fetchAndActivate()).thenThrow(Exception('offline'));
      stubFlag(
        FeatureFlag.payments,
        value: false,
        source: ValueSource.valueStatic,
      );

      await service.init();

      verify(crashlyticsService.log(any, any)).called(1);
      expect(service.isEnabled(FeatureFlag.payments), isTrue);
    });
  });

  group('isEnabled', () {
    test('returns the remote value when one was fetched', () {
      stubFlag(FeatureFlag.payments, value: false);

      expect(service.isEnabled(FeatureFlag.payments), isFalse);
    });

    test('falls back to the code default on an unknown key', () {
      // `valueStatic` means Remote Config has neither a default nor a fetched
      // value, and would answer `false` for every flag.
      stubFlag(
        FeatureFlag.payments,
        value: false,
        source: ValueSource.valueStatic,
      );

      expect(service.isEnabled(FeatureFlag.payments), isTrue);
    });
  });

  test('payments defaults to on so a fetch failure never kills billing', () {
    expect(FeatureFlag.payments.defaultValue, isTrue);
  });
}
