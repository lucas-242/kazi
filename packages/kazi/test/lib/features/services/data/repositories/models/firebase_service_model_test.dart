import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/data/repositories/models/firebase_service_model.dart';

void main() {
  group('FirebaseServiceModel currency serialization', () {
    test('round-trips currency and rates snapshot through toMap/fromMap', () {
      final model = FirebaseServiceModel(
        value: 100,
        discountPercent: 0,
        typeId: 'type-1',
        currency: 'BRL',
        rates: const {'USD': 1, 'BRL': 5.2},
        date: DateTime(2026, 7, 22),
        userId: 'user-1',
      );

      final restored = FirebaseServiceModel.fromMap(model.toMap());

      expect(restored.currency, 'BRL');
      expect(restored.rates, const {'USD': 1, 'BRL': 5.2});
    });

    test('defaults currency to empty and rates to null for legacy docs', () {
      final legacyMap = {
        'value': 50.0,
        'discountPercent': 0.0,
        'typeId': 'type-1',
        'date': DateTime(2026).toTimestampLike(),
        'userId': 'user-1',
      };

      final restored = FirebaseServiceModel.fromMap(legacyMap);

      expect(restored.currency, '');
      expect(restored.rates, isNull);
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
