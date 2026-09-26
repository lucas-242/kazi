import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/analytics/friction_detector.dart';
import 'package:kazi/core/services/domain/friction_kind.dart';

/// The detector's thresholds are the only guesses in the whole analytics stack,
/// so they are pinned here rather than discovered in production a week later.
///
/// It also carries the Android half of a feature PostHog only ships on iOS
/// (rage-click autocapture), which makes it the one thing here with no vendor
/// to fall back on.
void main() {
  late DateTime now;
  late List<({FrictionKind kind, String screen, int count})> detected;
  late FrictionDetector detector;

  setUp(() {
    now = DateTime(2026, 8, 20, 10);
    detected = [];
    detector = FrictionDetector(
      now: () => now,
      onDetected: (kind, screen, count) =>
          detected.add((kind: kind, screen: screen, count: count)),
    );
  });

  void advance(Duration by) => now = now.add(by);

  group('repeated error', () {
    test('fires on the second identical error inside the window', () {
      detector.onError(code: 'ExternalError', screen: 'add_services');
      expect(detected, isEmpty, reason: 'one error is not friction');

      advance(const Duration(seconds: 10));
      detector.onError(code: 'ExternalError', screen: 'add_services');

      expect(detected.single.kind, FrictionKind.repeatedError);
      expect(detected.single.screen, 'add_services');
    });

    test('does not fire once the first error has aged out', () {
      detector.onError(code: 'ExternalError', screen: 'add_services');
      advance(
        FrictionDetector.repeatedErrorWindow + const Duration(seconds: 1),
      );
      detector.onError(code: 'ExternalError', screen: 'add_services');

      expect(detected, isEmpty);
    });

    test('does not conflate two different errors', () {
      detector.onError(code: 'ExternalError', screen: 'add_services');
      detector.onError(code: 'ClientError', screen: 'add_services');

      expect(detected, isEmpty);
    });

    test('does not conflate the same error on two screens', () {
      detector.onError(code: 'ExternalError', screen: 'add_services');
      detector.onError(code: 'ExternalError', screen: 'home');

      expect(detected, isEmpty);
    });
  });

  group('rage tap', () {
    test('fires at the threshold within the window', () {
      for (var tap = 0; tap < FrictionDetector.rageTapThreshold; tap++) {
        detector.onTap(target: 'save', screen: 'add_services');
      }

      expect(detected.single.kind, FrictionKind.rageTap);
      expect(detected.single.count, FrictionDetector.rageTapThreshold);
    });

    test('does not fire for deliberate taps spread out in time', () {
      for (var tap = 0; tap < 5; tap++) {
        detector.onTap(target: 'save', screen: 'add_services');
        advance(const Duration(seconds: 2));
      }

      expect(detected, isEmpty);
    });
  });

  group('form stall', () {
    test('fires when a form is left after the threshold', () {
      detector.onFormAbandoned(
        form: 'service',
        elapsed: FrictionDetector.formStallThreshold,
        screen: 'add_services',
      );

      expect(detected.single.kind, FrictionKind.formStall);
    });

    test('does not fire for a form left quickly', () {
      detector.onFormAbandoned(
        form: 'service',
        elapsed: const Duration(seconds: 5),
        screen: 'add_services',
      );

      expect(detected, isEmpty);
    });
  });

  group('loop', () {
    test('fires on the second abandonment of the same form', () {
      detector.onFormAbandoned(
        form: 'service',
        elapsed: const Duration(seconds: 5),
        screen: 'add_services',
      );
      detector.onFormAbandoned(
        form: 'service',
        elapsed: const Duration(seconds: 5),
        screen: 'add_services',
      );

      expect(detected.single.kind, FrictionKind.loop);
    });

    test('a completed form clears the loop counter', () {
      detector.onFormAbandoned(
        form: 'service',
        elapsed: const Duration(seconds: 5),
        screen: 'add_services',
      );
      detector.onFormCompleted('service');
      detector.onFormAbandoned(
        form: 'service',
        elapsed: const Duration(seconds: 5),
        screen: 'add_services',
      );

      expect(
        detected,
        isEmpty,
        reason: 'they got where they were going; a later exit is a new story',
      );
    });
  });

  group('cooldown', () {
    test('reports one occurrence per kind per screen', () {
      for (var attempt = 0; attempt < 6; attempt++) {
        detector.onError(code: 'ExternalError', screen: 'add_services');
        advance(const Duration(seconds: 5));
      }

      expect(
        detected,
        hasLength(1),
        reason: 'hammering an unreachable server must not bury the first one',
      );
    });

    test('reports again once the cooldown has passed', () {
      detector
        ..onError(code: 'ExternalError', screen: 'add_services')
        ..onError(code: 'ExternalError', screen: 'add_services');
      advance(FrictionDetector.cooldown + const Duration(seconds: 1));
      detector
        ..onError(code: 'ExternalError', screen: 'add_services')
        ..onError(code: 'ExternalError', screen: 'add_services');

      expect(detected, hasLength(2));
    });
  });
}
