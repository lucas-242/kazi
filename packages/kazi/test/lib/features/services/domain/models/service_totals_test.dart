import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

void main() {
  Service service({
    double value = 100,
    double commissionPercent = 40,
    String currency = 'USD',
    DateTime? receivedAt,
  }) => Service(
    id: 'service-${value.toInt()}-$currency-${receivedAt?.day}',
    value: value,
    commissionPercent: commissionPercent,
    currency: currency,
    rateDate: '2026-08-20',
    date: DateTime(2026, 8, 20),
    receivedAt: receivedAt,
    userId: 'user-1',
  );

  ServiceTotals totalsOf(
    List<Service> services, {
    RateBook rateBook = const RateBook.empty(),
  }) => ServiceTotals.from(
    services,
    currency: SupportedCurrency.usd,
    rateBook: rateBook,
  );

  group('receivedCommission', () {
    test('Should be zero when nothing has been paid', () {
      final totals = totalsOf([service(), service(value: 50)]);

      expect(totals.receivedCommission, 0);
      expect(totals.hasReceived, isFalse);
    });

    test('Should sum only the paid services, as the user share', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 9, 5)),
        service(value: 50),
      ]);

      // 40% of 100 kept, and the unpaid 50 is not counted.
      expect(totals.receivedCommission, 40);
      expect(totals.commission, 60);
      expect(totals.hasReceived, isTrue);
    });

    /// Comparable to [ServiceTotals.commission] on purpose: the home shows
    /// them one under the other, so both have to be the user's own cut.
    test('Should equal the commission total once everything is paid', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 9, 5)),
        service(value: 50, receivedAt: DateTime(2026, 9, 5)),
      ]);

      expect(totals.receivedCommission, totals.commission);
      expect(totals.pendingCount, 0);
    });
  });

  group('pendingCount', () {
    test('Should count only the services still owed', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 9, 5)),
        service(value: 50),
        service(value: 70),
      ]);

      expect(totals.pendingCount, 2);
    });
  });

  group('Unconvertible services', () {
    /// The rule the whole totals type exists to enforce: an amount with no
    /// rate is left out rather than summed at face value. The received figure
    /// has to obey it too, or 100 BRL enters a USD total as 100.
    test('Should exclude a paid service that has no rate', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 9, 5)),
        service(value: 50, currency: 'BRL', receivedAt: DateTime(2026, 9, 5)),
      ]);

      expect(totals.receivedCommission, 40);
      expect(totals.unconverted, 1);
      expect(totals.isPartial, isTrue);
    });

    test('Should count an unconvertible service once, not once per amount', () {
      final totals = totalsOf([service(currency: 'BRL')]);

      expect(totals.unconverted, 1);
    });

    test('Should leave an unconvertible service out of pendingCount', () {
      final totals = totalsOf([service(currency: 'BRL'), service(value: 50)]);

      expect(totals.pendingCount, 1);
    });
  });

  group('pendingCommission', () {
    // The identity every screen showing the three figures reads out loud:
    // "já recebido + pendente = seu ganho".
    test('Should add up to the commission alongside receivedCommission', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 8, 21)),
        service(value: 50),
        service(value: 200, commissionPercent: 25),
      ]);

      expect(totals.commission, 110);
      expect(totals.receivedCommission, 40);
      expect(totals.pendingCommission, 70);
      expect(
        totals.receivedCommission + totals.pendingCommission,
        totals.commission,
      );
    });

    test('Should hold when nothing has been paid', () {
      final totals = totalsOf([service(), service(value: 50)]);

      expect(totals.pendingCommission, totals.commission);
    });

    test('Should hold when everything has been paid', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 8, 21)),
        service(value: 50, receivedAt: DateTime(2026, 8, 22)),
      ]);

      expect(totals.pendingCommission, 0);
    });

    // An unconvertible service is out of both figures, so the identity is
    // between what converted — never between a full gross and a partial share.
    test('Should hold when a service is left out for want of a rate', () {
      final totals = totalsOf([
        service(currency: 'BRL'),
        service(receivedAt: DateTime(2026, 8, 21)),
        service(value: 50),
      ]);

      expect(totals.isPartial, isTrue);
      expect(
        totals.receivedCommission + totals.pendingCommission,
        totals.commission,
      );
    });
  });
}
