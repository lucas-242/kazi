import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

void main() {
  Service service({
    double value = 100,
    double discountPercent = 60,
    String currency = 'USD',
    DateTime? receivedAt,
  }) => Service(
    id: 'service-${value.toInt()}-$currency-${receivedAt?.day}',
    value: value,
    discountPercent: discountPercent,
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

  group('receivedWithDiscount', () {
    test('Should be zero when nothing has been paid', () {
      final totals = totalsOf([service(), service(value: 50)]);

      expect(totals.receivedWithDiscount, 0);
      expect(totals.hasReceived, isFalse);
    });

    test('Should sum only the paid services, as the user share', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 9, 5)),
        service(value: 50),
      ]);

      // 40% of 100 kept, and the unpaid 50 is not counted.
      expect(totals.receivedWithDiscount, 40);
      expect(totals.withDiscount, 60);
      expect(totals.hasReceived, isTrue);
    });

    /// Comparable to [ServiceTotals.withDiscount] on purpose: the home shows
    /// them one under the other, so both have to be the user's own cut.
    test('Should equal withDiscount once everything is paid', () {
      final totals = totalsOf([
        service(receivedAt: DateTime(2026, 9, 5)),
        service(value: 50, receivedAt: DateTime(2026, 9, 5)),
      ]);

      expect(totals.receivedWithDiscount, totals.withDiscount);
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

      expect(totals.receivedWithDiscount, 40);
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
}
