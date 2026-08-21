import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/analytics/analytics_scrubber.dart';

/// The scrubber is the promise "no event carries an amount, a name, an e-mail
/// or free text" turned into something that can fail a build. Everything here
/// is a leak that would otherwise reach two third-party vendors and could not
/// be recalled.
void main() {
  group('text denylist', () {
    test('redacts a client name however the key spells it', () {
      final safe = AnalyticsScrubber.scrub({
        'client_name': 'Maria Silva',
        'customer': 'Maria Silva',
        'name': 'Maria Silva',
        'last_name': 'Silva',
      });

      expect(
        safe.values,
        everyElement(AnalyticsScrubber.redacted),
        reason: 'every key naming a person must be redacted',
      );
    });

    test('redacts free text fields', () {
      final safe = AnalyticsScrubber.scrub({
        'note': 'paid half up front, rest on friday',
        'description': 'kitchen renovation',
        'address': 'Rua das Flores 100',
        'phone': '+5511999999999',
      });

      expect(safe.values, everyElement(AnalyticsScrubber.redacted));
    });

    test('redacts anything that looks like an e-mail, whatever the key', () {
      final safe = AnalyticsScrubber.scrub({'step': 'someone@example.com'});

      expect(safe['step'], AnalyticsScrubber.redacted);
    });

    test('lets a boolean through even under a denied key', () {
      // `has_client` says whether a client was attached, not who. Redacting it
      // would cost a real breakdown for no privacy gain.
      final safe = AnalyticsScrubber.scrub({'has_client': true});

      expect(safe['has_client'], isTrue);
    });
  });

  group('numeric denylist', () {
    test('redacts monetary figures', () {
      final safe = AnalyticsScrubber.scrub({
        'value': 1500.0,
        'amount': 1500,
        'total': 1500,
        'commission_value': 750.0,
      });

      expect(
        safe.values,
        everyElement(AnalyticsScrubber.redacted),
        reason: 'what a user earns must never reach an analytics vendor',
      );
    });

    test('lets counts through', () {
      final safe = AnalyticsScrubber.scrub({
        'services_bucket': 12,
        'unconverted_count': 3,
        'seeded_types': 5,
        'quantity': 2,
        'seconds': 41,
      });

      expect(safe, hasLength(5));
      expect(safe['services_bucket'], 12);
      expect(safe['seconds'], 41);
    });
  });

  group('shape', () {
    test('truncates a long string to the Firebase limit', () {
      final safe = AnalyticsScrubber.scrub({'step': 'x' * 500});

      expect(
        (safe['step']! as String).length,
        AnalyticsScrubber.maxValueLength,
      );
    });

    test('caps the number of parameters at the Firebase limit', () {
      final safe = AnalyticsScrubber.scrub({
        for (var i = 0; i < 40; i++) 'p$i': i,
      });

      expect(safe, hasLength(AnalyticsScrubber.maxParameters));
    });

    test('reduces a collection to its size', () {
      final safe = AnalyticsScrubber.scrub({
        'types': ['haircut', 'beard', 'colour'],
      });

      expect(safe['types'], 3);
    });

    test('reduces an unexpected object to its type, never its toString', () {
      final safe = AnalyticsScrubber.scrub({'when': DateTime(2026, 8, 20)});

      expect(safe['when'], 'DateTime');
    });

    test('passes an empty map through untouched', () {
      expect(AnalyticsScrubber.scrub(const {}), isEmpty);
    });
  });
}
