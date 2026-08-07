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
