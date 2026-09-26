import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

void main() {
  // 1 USD = 5 BRL in the frozen snapshot.
  const snapshot = {'USD': 1.0, 'BRL': 5.0};

  final day = DateTime.utc(2026, 3, 10);
  final dayKey = ExchangeRates.dateKeyOf(day);

  final book = RateBook(
    byDate: {dayKey: ExchangeRates(rates: snapshot, fetchedAt: day)},
  );

  Service service({
    required double value,
    required String currency,
    String rateDate = '',
  }) => Service(
    value: value,
    currency: currency,
    rateDate: rateDate,
    date: day,
    userId: 'user-1',
  );

  group('DashboardState totals with mixed currencies', () {
    test('converts each service to the default currency before summing', () {
      final state = DashboardState(
        status: BaseStateStatus.success,
        defaultCurrency: SupportedCurrency.brl,
        rateBook: book,
        services: [
          service(value: 20, currency: 'USD', rateDate: dayKey), // -> 100 BRL
          service(value: 50, currency: 'BRL', rateDate: dayKey),
        ],
      );

      expect(state.totals.value, 150);
      expect(state.totals.isPartial, isFalse);
    });

    test('falls back to the service date when no rateDate was stored', () {
      final state = DashboardState(
        status: BaseStateStatus.success,
        defaultCurrency: SupportedCurrency.brl,
        rateBook: book,
        services: [service(value: 20, currency: 'USD')],
      );

      expect(state.totals.value, 100);
    });

    test(
      'leaves out services with no usable rate instead of summing them raw',
      () {
        final state = DashboardState(
          status: BaseStateStatus.success,
          defaultCurrency: SupportedCurrency.brl,
          services: [
            service(value: 20, currency: 'USD'), // no rate book at all
            service(value: 50, currency: 'BRL'), // same currency, no rate used
          ],
        );

        expect(state.totals.value, 50);
        expect(state.totals.unconverted, 1);
        expect(state.totals.isPartial, isTrue);
      },
    );

    test('a currency added after the snapshot still converts', () {
      // The snapshot on the service's date predates ARS support and can never
      // gain it — the daily documents are immutable. It must fall back to a
      // newer snapshot rather than dropping the service from the total.
      final withArs = ExchangeRates(
        rates: const {'USD': 1.0, 'BRL': 5.0, 'ARS': 1500.0},
        fetchedAt: DateTime.utc(2026, 8, 7),
      );

      final state = DashboardState(
        status: BaseStateStatus.success,
        defaultCurrency: SupportedCurrency.ars,
        rateBook: book.merge({'2026-08-07': withArs}),
        services: [service(value: 20, currency: 'USD', rateDate: dayKey)],
      );

      expect(state.totals.value, 30000);
      expect(state.totals.isPartial, isFalse);
    });

    test('legacy services with no currency assume the default', () {
      final state = DashboardState(
        status: BaseStateStatus.success,
        defaultCurrency: SupportedCurrency.brl,
        rateBook: book,
        services: [
          Service(value: 20, date: day, userId: 'user-1'),
          Service(value: 50, date: day, userId: 'user-1'),
        ],
      );

      expect(state.totals.value, 70);
      expect(state.totals.isPartial, isFalse);
    });
  });
}
