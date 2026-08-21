import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/analytics/composite_analytics_service.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';

import '../../../../../utils/fakes/fake_analytics_service.dart';

/// A sink that fails at everything, to prove the other one still gets its call.
class _BrokenAnalyticsService implements AnalyticsService {
  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  }) async => throw StateError('sink is down');

  @override
  Future<void> screen(
    String name, {
    Map<String, Object> parameters = const {},
  }) async => throw StateError('sink is down');

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  }) async => throw StateError('sink is down');

  @override
  Future<void> setUserProperties(Map<String, Object> properties) async =>
      throw StateError('sink is down');

  @override
  Future<void> reset() async => throw StateError('sink is down');
}

void main() {
  late FakeAnalyticsService firebase;
  late FakeAnalyticsService postHog;

  setUp(() {
    firebase = FakeAnalyticsService();
    postHog = FakeAnalyticsService();
  });

  CompositeAnalyticsService build({
    bool isEnabled = true,
    AnalyticsService? firebaseSink,
    AnalyticsService? postHogSink,
  }) => CompositeAnalyticsService(
    firebase: firebaseSink ?? firebase,
    postHog: postHogSink ?? postHog,
    isEnabled: () => isEnabled,
  );

  group('routing', () {
    test('a key event reaches both sinks', () async {
      await build().log(AnalyticsEvent.subscriptionStarted);

      expect(firebase.events, contains(AnalyticsEvent.subscriptionStarted));
      expect(postHog.events, contains(AnalyticsEvent.subscriptionStarted));
    });

    test('a non-key event reaches PostHog only', () async {
      await build().log(AnalyticsEvent.serviceFormAbandoned);

      expect(
        firebase.events,
        isEmpty,
        reason:
            'Firebase caps event names and drives Ads audiences; '
            'diagnostics must not dilute it',
      );
      expect(postHog.events, contains(AnalyticsEvent.serviceFormAbandoned));
    });

    test('identity reaches both sinks regardless of event routing', () async {
      await build().identify('uid-1', properties: {'tier': 'premium'});

      expect(firebase.identifiedUserId, 'uid-1');
      expect(postHog.identifiedUserId, 'uid-1');
      expect(firebase.userProperties['tier'], 'premium');
    });

    test('screens reach both sinks', () async {
      await build().screen('home');

      expect(firebase.screens, ['home']);
      expect(postHog.screens, ['home']);
    });
  });

  group('consent gate', () {
    test('nothing is sent while consent is withheld', () async {
      final composite = build(isEnabled: false);

      await composite.log(AnalyticsEvent.subscriptionStarted);
      await composite.screen('home');
      await composite.identify('uid-1');
      await composite.setUserProperties({'tier': 'free'});

      expect(firebase.events, isEmpty);
      expect(postHog.events, isEmpty);
      expect(postHog.screens, isEmpty);
      expect(postHog.identifiedUserId, isNull);
    });

    test('reset still runs while consent is withheld', () async {
      await build(isEnabled: false).reset();

      expect(
        postHog.resetCount,
        1,
        reason:
            'forgetting who someone was is the one thing a withdrawn '
            'consent must never block',
      );
    });

    test('a throwing gate is treated as no consent, not as a crash', () async {
      final composite = CompositeAnalyticsService(
        firebase: firebase,
        postHog: postHog,
        isEnabled: () => throw StateError('providers unavailable'),
      );

      await expectLater(
        composite.log(AnalyticsEvent.loginCompleted),
        completes,
      );
      expect(firebase.events, isEmpty);
      expect(postHog.events, isEmpty);
    });
  });

  group('isolation', () {
    test('a broken Firebase sink does not cost PostHog its event', () async {
      await build(
        firebaseSink: _BrokenAnalyticsService(),
      ).log(AnalyticsEvent.subscriptionStarted);

      expect(postHog.events, contains(AnalyticsEvent.subscriptionStarted));
    });

    test('a broken PostHog sink does not cost Firebase its event', () async {
      await build(
        postHogSink: _BrokenAnalyticsService(),
      ).log(AnalyticsEvent.subscriptionStarted);

      expect(firebase.events, contains(AnalyticsEvent.subscriptionStarted));
    });

    test('a broken sink never throws at the caller', () async {
      final composite = build(
        firebaseSink: _BrokenAnalyticsService(),
        postHogSink: _BrokenAnalyticsService(),
      );

      await expectLater(
        composite.log(AnalyticsEvent.serviceCreated),
        completes,
        reason: 'every caller sits on a path the user is walking',
      );
    });
  });
}
