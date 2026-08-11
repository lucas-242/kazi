import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_breakdown.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, ServiceType;

void main() {
  // 1 USD = 5 BRL in the frozen snapshot.
  const snapshot = {'USD': 1.0, 'BRL': 5.0};

  final day = DateTime.utc(2026, 8, 20);
  final dayKey = ExchangeRates.dateKeyOf(day);

  final book = RateBook(
    byDate: {dayKey: ExchangeRates(rates: snapshot, fetchedAt: day)},
  );

  ServiceType type(String id, {String name = 'Gel', String color = ''}) =>
      ServiceType(id: id, name: name, color: color, userId: 'user-1');

  Service service({
    double value = 100,
    double commissionPercent = 40,
    // Empty means "the profile default", which is what the breakdown converts
    // into — so services that do not name a currency need no rate at all.
    String currency = '',
    String rateDate = '',
    ServiceType? serviceType,
    String typeId = 'type-default',
    String? clientId,
    String? clientName,
  }) => Service(
    id: 'service-${value.toInt()}-$currency-$typeId-$clientId',
    value: value,
    commissionPercent: commissionPercent,
    currency: currency,
    rateDate: rateDate.isEmpty ? dayKey : rateDate,
    date: day,
    type: serviceType,
    typeId: typeId,
    clientId: clientId,
    clientName: clientName,
    userId: 'user-1',
  );

  ServiceBreakdown byType(
    List<Service> services, {
    SupportedCurrency currency = SupportedCurrency.usd,
    RateBook rateBook = const RateBook.empty(),
  }) => ServiceBreakdown.byType(
    services,
    currency: currency,
    rateBook: rateBook,
    untypedLabel: 'Without type',
  );

  ServiceBreakdown byClient(
    List<Service> services, {
    SupportedCurrency currency = SupportedCurrency.usd,
    RateBook rateBook = const RateBook.empty(),
  }) => ServiceBreakdown.byClient(
    services,
    currency: currency,
    rateBook: rateBook,
  );

  group('byType', () {
    test('Should sum the services of each type into one slice', () {
      final breakdown = byType([
        service(typeId: 'type-1', serviceType: type('type-1')),
        service(value: 50, typeId: 'type-1', serviceType: type('type-1')),
        service(
          value: 20,
          typeId: 'type-2',
          serviceType: type('type-2', name: 'Spa'),
        ),
      ]);

      expect(breakdown.slices.length, 2);
      expect(breakdown.slices.first.id, 'type-1');
      expect(breakdown.slices.first.value, 150);
      expect(breakdown.slices.first.count, 2);
      // 40% of 150 kept.
      expect(breakdown.slices.first.commission, 60);
    });

    test('Should order the slices by gross, largest first', () {
      final breakdown = byType([
        service(value: 10, typeId: 'small'),
        service(value: 900, typeId: 'big'),
        service(value: 300, typeId: 'middle'),
      ]);

      expect(breakdown.slices.map((slice) => slice.id), [
        'big',
        'middle',
        'small',
      ]);
      // The denominator every bar is drawn against.
      expect(breakdown.max, 900);
    });

    test('Should label a service that has no type rather than drop it', () {
      final breakdown = byType([service(typeId: '')]);

      expect(breakdown.slices.single.label, 'Without type');
      expect(breakdown.slices.single.value, 100);
    });

    test('Should carry the type colour onto the slice', () {
      final breakdown = byType([
        service(
          typeId: 'type-1',
          serviceType: type('type-1', color: 'FFE255A1'),
        ),
      ]);

      expect(breakdown.slices.single.color, const Color(0xFFE255A1));
    });

    test('Should convert each service before summing it into a slice', () {
      final breakdown = byType(
        [
          // 20 USD -> 100 BRL, into the same slice as a service already in BRL.
          service(value: 20, currency: 'USD', typeId: 'type-1'),
          service(value: 50, currency: 'BRL', typeId: 'type-1'),
        ],
        currency: SupportedCurrency.brl,
        rateBook: book,
      );

      expect(breakdown.slices.single.value, 150);
      expect(breakdown.unconverted, 0);
    });

    test('Should leave an unconvertible service out and count it', () {
      final breakdown = byType([
        service(value: 50, currency: 'BRL', typeId: 'type-1'),
        // No rate to reach BRL: must not enter the bar at face value.
        service(value: 20, currency: 'USD', typeId: 'type-1'),
      ], currency: SupportedCurrency.brl);

      expect(breakdown.slices.single.value, 50);
      expect(breakdown.slices.single.count, 1);
      expect(breakdown.unconverted, 1);
    });

    test('Should be empty for no services', () {
      final breakdown = byType([]);

      expect(breakdown.isEmpty, isTrue);
      expect(breakdown.max, 0);
    });
  });

  group('byClient', () {
    test('Should sum the services of each client into one slice', () {
      final breakdown = byClient([
        service(clientId: 'client-1', clientName: 'Marina'),
        service(value: 50, clientId: 'client-1', clientName: 'Marina'),
        service(value: 20, clientId: 'client-2', clientName: 'Júlia'),
      ]);

      expect(breakdown.slices.length, 2);
      expect(breakdown.slices.first.label, 'Marina');
      expect(breakdown.slices.first.value, 150);
      expect(breakdown.slices.first.count, 2);
    });

    test('Should skip services with no client', () {
      final breakdown = byClient([
        service(clientId: 'client-1', clientName: 'Marina'),
        service(value: 900),
      ]);

      expect(breakdown.slices.single.label, 'Marina');
      expect(breakdown.slices.single.value, 100);
    });

    test('Should skip a client whose name is missing', () {
      final breakdown = byClient([service(clientId: 'client-1')]);

      expect(breakdown.isEmpty, isTrue);
    });

    test('Should be empty when nothing has a client', () {
      expect(byClient([service(), service(value: 50)]).isEmpty, isTrue);
    });

    test('Should keep the first name seen when a snapshot goes stale', () {
      final breakdown = byClient([
        service(clientId: 'client-1', clientName: 'Marina Rocha'),
        service(value: 1, clientId: 'client-1', clientName: 'Marina R.'),
      ]);

      expect(breakdown.slices.single.label, 'Marina Rocha');
      expect(breakdown.slices.single.count, 2);
    });
  });

  group('top', () {
    test('Should return only the largest slices, in order', () {
      final breakdown = byClient([
        for (var index = 1; index <= 8; index++)
          service(
            value: index * 10,
            clientId: 'client-$index',
            clientName: 'Client $index',
          ),
      ]);

      final top = breakdown.top(5);

      expect(top.length, 5);
      expect(top.first.label, 'Client 8');
      expect(top.last.label, 'Client 4');
    });

    test('Should return everything when there are fewer than asked for', () {
      final breakdown = byClient([
        service(clientId: 'client-1', clientName: 'Marina'),
      ]);

      expect(breakdown.top(5).length, 1);
    });
  });
}
