import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/features/settings/presenter/controllers/privacy_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import '../../../../../utils/fakes/fake_local_storage.dart';

/// The two switches are the app's answer to the LGPD right to object, so
/// "declined" surviving a restart and "not asked" staying askable are legal
/// behaviour, not conveniences.
void main() {
  late FakeLocalStorage storage;

  ProviderContainer containerWith([Map<String, Object?> stored = const {}]) {
    storage = FakeLocalStorage(stored);
    return ProviderContainer(
      overrides: [localStorageProvider.overrideWith((ref) async => storage)],
    );
  }

  test('defaults to analytics allowed and the replay question unasked', () async {
    final container = containerWith();
    addTearDown(container.dispose);

    final settings = await container.read(privacyControllerProvider.future);

    expect(settings.isAnalyticsAllowed, isTrue);
    expect(settings.needsReplayPrompt, isTrue);
    expect(
      settings.isReplayAllowed,
      isFalse,
      reason: 'never asked is never consent',
    );
  });

  test('a declined replay answer is not the same as an unasked one', () async {
    final container = containerWith({StorageKeys.sessionReplayConsent: false});
    addTearDown(container.dispose);

    final settings = await container.read(privacyControllerProvider.future);

    expect(settings.isReplayAllowed, isFalse);
    expect(
      settings.needsReplayPrompt,
      isFalse,
      reason: 'someone who said no must not be asked again',
    );
  });

  test('objecting to analytics is persisted', () async {
    final container = containerWith();
    addTearDown(container.dispose);
    await container.read(privacyControllerProvider.future);

    await container
        .read(privacyControllerProvider.notifier)
        .setAnalyticsEnabled(false);

    expect(container.read(isAnalyticsAllowedProvider), isFalse);
    expect(storage.values[StorageKeys.analyticsOptOut], isTrue);
  });

  test('consenting to replay is persisted and exposed', () async {
    final container = containerWith();
    addTearDown(container.dispose);
    await container.read(privacyControllerProvider.future);

    await container
        .read(privacyControllerProvider.notifier)
        .setSessionReplayConsent(true);

    expect(container.read(isReplayAllowedProvider), isTrue);
    expect(storage.values[StorageKeys.sessionReplayConsent], isTrue);
  });

  test('withdrawing replay consent is persisted', () async {
    final container = containerWith({StorageKeys.sessionReplayConsent: true});
    addTearDown(container.dispose);
    await container.read(privacyControllerProvider.future);

    await container
        .read(privacyControllerProvider.notifier)
        .setSessionReplayConsent(false);

    expect(container.read(isReplayAllowedProvider), isFalse);
    expect(storage.values[StorageKeys.sessionReplayConsent], isFalse);
  });

  test('the gate answers "not allowed" while the store is still loading', () {
    final container = containerWith();
    addTearDown(container.dispose);

    // Read without awaiting: the handful of events in the first milliseconds
    // are worth less than one event sent for somebody who had already objected.
    expect(container.read(isAnalyticsAllowedProvider), isFalse);
    expect(container.read(isReplayAllowedProvider), isFalse);
  });
}
