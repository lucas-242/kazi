import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';

void main() {
  group('FirebaseServiceModel currency serialization', () {
    test('round-trips currency and rate anchor through toMap/fromMap', () {
      final model = FirebaseServiceModel(
        value: 100,
        discountPercent: 0,
        typeId: 'type-1',
        currency: 'BRL',
        rateDate: '2026-07-22',
        date: DateTime(2026, 7, 22),
        userId: 'user-1',
      );

      final restored = FirebaseServiceModel.fromMap(model.toMap());

      expect(restored.currency, 'BRL');
      expect(restored.rateDate, '2026-07-22');
    });

    test('never writes an embedded rates map', () {
      // A full copy of every rate on every service does not scale, and goes
      // stale the moment a new currency is added. The anchor points at the
      // shared daily snapshot instead.
      final model = FirebaseServiceModel(
        value: 100,
        discountPercent: 0,
        typeId: 'type-1',
        currency: 'BRL',
        rateDate: '2026-07-22',
        date: DateTime(2026, 7, 22),
        userId: 'user-1',
      );

      expect(model.toMap().containsKey('rates'), isFalse);
    });

    test('ignores a stray rates field left on an old document', () {
      final oldMap = {
        'value': 100.0,
        'discountPercent': 0.0,
        'typeId': 'type-1',
        'currency': 'BRL',
        'rates': const {'USD': 1, 'BRL': 5.2},
        'date': DateTime(2026, 7, 22).toTimestampLike(),
        'userId': 'user-1',
      };

      final restored = FirebaseServiceModel.fromMap(oldMap);

      expect(restored.currency, 'BRL');
      expect(restored.rateDate, '');
    });

    test('defaults currency and rateDate to empty for legacy docs', () {
      final legacyMap = {
        'value': 50.0,
        'discountPercent': 0.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      };

      final restored = FirebaseServiceModel.fromMap(legacyMap);

      expect(restored.currency, '');
      expect(restored.rateDate, '');
    });

    test('effectiveRateDate falls back to the service date', () {
      final model = FirebaseServiceModel(
        value: 50,
        discountPercent: 0,
        typeId: 'type-1',
        date: DateTime.utc(2026, 7, 22),
        userId: 'user-1',
      );

      expect(model.effectiveRateDate, '2026-07-22');
    });
  });

  group('FirebaseServiceModel payment stamp', () {
    FirebaseServiceModel model({DateTime? receivedAt}) => FirebaseServiceModel(
      value: 100,
      discountPercent: 0,
      typeId: 'type-1',
      date: DateTime(2026, 8, 20),
      receivedAt: receivedAt,
      userId: 'user-1',
    );

    test('round-trips receivedAt through toMap/fromMap', () {
      final restored = FirebaseServiceModel.fromMap(
        model(receivedAt: DateTime(2026, 9, 5)).toMap(),
      );

      expect(restored.receivedAt, DateTime(2026, 9, 5));
      expect(restored.isReceived, isTrue);
    });

    test('round-trips an unpaid service as null', () {
      final restored = FirebaseServiceModel.fromMap(model().toMap());

      expect(restored.receivedAt, isNull);
      expect(restored.isReceived, isFalse);
    });

    /// The asymmetry that rules out a Firestore `isNull: true` query: services
    /// written before payment tracking carry no such key, while new ones carry
    /// an explicit null. Both must read as unpaid.
    test('reads a legacy doc with no receivedAt key as unpaid', () {
      final legacyMap = {
        'value': 50.0,
        'discountPercent': 0.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      };

      final restored = FirebaseServiceModel.fromMap(legacyMap);

      expect(restored.receivedAt, isNull);
      expect(restored.isReceived, isFalse);
    });

    test('writes receivedAt as a Timestamp', () {
      final written = model(receivedAt: DateTime(2026, 9, 5)).toMap();

      expect(written['receivedAt'], isA<Timestamp>());
    });

    test('markedReceivedAt stamps without disturbing the rate anchor', () {
      final source = FirebaseServiceModel(
        value: 100,
        discountPercent: 0,
        typeId: 'type-1',
        currency: 'BRL',
        rateDate: '2026-08-20',
        date: DateTime(2026, 8, 20),
        userId: 'user-1',
      );

      final paid = source.markedReceivedAt(DateTime(2026, 9, 5));

      expect(paid.receivedAt, DateTime(2026, 9, 5));
      expect(paid.rateDate, '2026-08-20');
      expect(paid.date, DateTime(2026, 8, 20));
    });

    /// `copyWith(receivedAt: null)` reads as "leave it alone", so clearing needs
    /// its own transition — the reason [Service.notReceived] exists at all.
    test('notReceived clears the stamp where copyWith cannot', () {
      final paid = model(receivedAt: DateTime(2026, 9, 5));

      expect(paid.copyWith().receivedAt, DateTime(2026, 9, 5));
      expect(paid.notReceived().receivedAt, isNull);
    });

    test('copyWith preserves the stamp when editing other fields', () {
      final paid = model(receivedAt: DateTime(2026, 9, 5));

      expect(paid.copyWith(value: 250).receivedAt, DateTime(2026, 9, 5));
    });

    test('fromService carries the stamp', () {
      final paid = model(receivedAt: DateTime(2026, 9, 5));

      expect(
        FirebaseServiceModel.fromService(paid).receivedAt,
        DateTime(2026, 9, 5),
      );
    });
  });

  group('FirebaseServiceModel commission', () {
    test('reads a legacy discount as the complementary commission', () {
      final legacyMap = {
        'value': 100.0,
        'discountPercent': 40.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      };

      final restored = FirebaseServiceModel.fromMap(legacyMap);

      expect(restored.effectiveCommissionPercent, 60);
      expect(restored.commissionValue, 60);
      expect(restored.withheldValue, 40);
    });

    test('reads a document with neither field as a full commission', () {
      final map = {
        'value': 100.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      };

      final restored = FirebaseServiceModel.fromMap(map);

      expect(restored.effectiveCommissionPercent, 100);
      expect(restored.commissionValue, 100);
      expect(restored.withheldValue, 0);
    });

    test('prefers the commission over a stale discount left on the doc', () {
      final map = {
        'value': 100.0,
        'commissionPercent': 70.0,
        'discountPercent': 40.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      };

      expect(FirebaseServiceModel.fromMap(map).effectiveCommissionPercent, 70);
    });

    /// App versions released before the commission field read
    /// `discountPercent` into a non-nullable field: dropping the key would
    /// break them outright, so every write still mirrors it.
    test('writes the legacy discount mirror alongside the commission', () {
      final model = FirebaseServiceModel(
        value: 100,
        commissionPercent: 70,
        typeId: 'type-1',
        date: DateTime(2026, 8, 20),
        userId: 'user-1',
      );

      final written = model.toMap();

      expect(written['commissionPercent'], 70);
      expect(written['discountPercent'], 30);
    });

    test('mirrors a service with no commission as a zero discount', () {
      final model = FirebaseServiceModel(
        value: 100,
        typeId: 'type-1',
        date: DateTime(2026, 8, 20),
        userId: 'user-1',
      );

      final written = model.toMap();

      expect(written['commissionPercent'], 100);
      expect(written['discountPercent'], 0);
    });

    test('an edited legacy service stops depending on the old field', () {
      final legacy = FirebaseServiceModel.fromMap({
        'value': 100.0,
        'discountPercent': 40.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      });

      final edited = legacy.copyWith(commissionPercent: 80);
      final restored = FirebaseServiceModel.fromMap(edited.toMap());

      expect(restored.effectiveCommissionPercent, 80);
      expect(restored.toMap()['discountPercent'], 20);
    });
  });
}

/// Firestore stores dates as Timestamp (exposing millisecondsSinceEpoch);
/// this stand-in mirrors that shape for the legacy-map test.
extension on DateTime {
  _TimestampLike toTimestampLike() => _TimestampLike(millisecondsSinceEpoch);
}

class _TimestampLike {
  const _TimestampLike(this.millisecondsSinceEpoch);
  final int millisecondsSinceEpoch;
}
