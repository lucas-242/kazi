import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/remote_config_keys.dart';
import 'package:kazi/core/services/data/banner_ad_policy.dart';

class _FakeRemoteConfig implements FirebaseRemoteConfig {
  _FakeRemoteConfig(this._frequency);

  final int _frequency;

  @override
  int getInt(String key) =>
      key == RemoteConfigKeys.bannerAdFrequency ? _frequency : 0;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  BannerAdPolicy build({int frequency = 3, bool isPremium = false}) =>
      BannerAdPolicy(
        isPremium: isPremium,
        remoteConfig: _FakeRemoteConfig(frequency),
      );

  test('shows a banner every N items, never at index 0', () {
    final policy = build();

    expect(policy.frequency, 3);
    expect(policy.shouldShowAt(0), isFalse);
    expect(policy.shouldShowAt(1), isFalse);
    expect(policy.shouldShowAt(2), isFalse);
    expect(policy.shouldShowAt(3), isTrue);
    expect(policy.shouldShowAt(6), isTrue);
  });

  test('premium users never see a banner', () {
    final policy = build(isPremium: true);

    expect(policy.shouldShowAt(3), isFalse);
    expect(policy.shouldShowAt(6), isFalse);
  });

  test('falls back to the default frequency when remote config is unset', () {
    // frequency 0 => getInt returns 0 => policy uses its default of 3.
    final policy = build(frequency: 0);

    expect(policy.frequency, 3);
    expect(policy.shouldShowAt(3), isTrue);
  });

  test('honors a remotely configured frequency', () {
    final policy = build(frequency: 5);

    expect(policy.shouldShowAt(3), isFalse);
    expect(policy.shouldShowAt(5), isTrue);
    expect(policy.shouldShowAt(10), isTrue);
  });
}
