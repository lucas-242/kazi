import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';

void main() {
  group('effectiveCommissionPercent', () {
    test('reads a legacy discount as the complementary commission', () {
      final type = CatalogItem.fromMap({
        'name': 'Barber',
        'discountPercent': 40.0,
        'userId': 'user-1',
      });

      expect(type.effectiveCommissionPercent, 60);
    });

    /// Null all the way through rather than 100: the *type* configures nothing,
    /// and it is the service form that turns that into "keeps everything".
    test('is null when the type configures neither field', () {
      final type = CatalogItem.fromMap({'name': 'Barber', 'userId': 'user-1'});

      expect(type.effectiveCommissionPercent, isNull);
    });

    test('prefers the commission over a stale discount', () {
      final type = CatalogItem.fromMap({
        'name': 'Barber',
        'commissionPercent': 70.0,
        'discountPercent': 40.0,
        'userId': 'user-1',
      });

      expect(type.effectiveCommissionPercent, 70);
    });
  });

  group('toMap', () {
    /// App versions released before the commission field read only
    /// `discountPercent`, so every write still mirrors it — otherwise an edited
    /// type would read as a 0% discount there.
    test('writes the legacy discount mirror alongside the commission', () {
      const type = CatalogItem(
        name: 'Barber',
        commissionPercent: 70,
        userId: 'user-1',
      );

      final written = type.toMap();

      expect(written['commissionPercent'], 70);
      expect(written['discountPercent'], 30);
    });

    test('leaves an untouched legacy type on its own discount', () {
      final type = CatalogItem.fromMap({
        'name': 'Barber',
        'discountPercent': 40.0,
        'userId': 'user-1',
      });

      final written = type.toMap();

      expect(written['commissionPercent'], isNull);
      expect(written['discountPercent'], 40.0);
      // Nothing was lost: it still resolves to the same commission.
      expect(CatalogItem.fromMap(written).effectiveCommissionPercent, 60);
    });

    test('an edited legacy type stops depending on the old field', () {
      final type = CatalogItem.fromMap({
        'name': 'Barber',
        'discountPercent': 40.0,
        'userId': 'user-1',
      }).copyWith(commissionPercent: 80);

      final restored = CatalogItem.fromMap(type.toMap());

      expect(restored.effectiveCommissionPercent, 80);
      expect(restored.toMap()['discountPercent'], 20);
    });

    test('writes both as null when nothing is configured', () {
      const type = CatalogItem(name: 'Barber', userId: 'user-1');

      final written = type.toMap();

      expect(written['commissionPercent'], isNull);
      expect(written['discountPercent'], isNull);
    });
  });

  group('defaultDuration', () {
    test('round-trips as whole minutes', () {
      const type = CatalogItem(
        name: 'Barber',
        defaultDuration: Duration(minutes: 45),
        userId: 'user-1',
      );

      final written = type.toMap();

      expect(written['defaultDurationMinutes'], 45);
      expect(
        CatalogItem.fromMap(written).defaultDuration,
        const Duration(minutes: 45),
      );
    });

    test('reads a legacy document with no duration as unset', () {
      final type = CatalogItem.fromMap({'name': 'Barber', 'userId': 'user-1'});

      expect(type.defaultDuration, isNull);
    });

    test('reads a non-positive duration as unset', () {
      final type = CatalogItem.fromMap({
        'name': 'Barber',
        'defaultDurationMinutes': 0,
        'userId': 'user-1',
      });

      expect(type.defaultDuration, isNull);
    });

    test('survives restoring an archived item', () {
      final archived = CatalogItem(
        name: 'Barber',
        defaultDuration: const Duration(hours: 1),
        archivedAt: DateTime(2026, 9),
        userId: 'user-1',
      );

      expect(archived.restored().defaultDuration, const Duration(hours: 1));
    });

    test('withDefaultDuration clears it and keeps everything else', () {
      final archived = CatalogItem(
        name: 'Barber',
        commissionPercent: 60,
        defaultDuration: const Duration(hours: 1),
        archivedAt: DateTime(2026, 9),
        userId: 'user-1',
      );

      final cleared = archived.withDefaultDuration(null);

      expect(cleared.defaultDuration, isNull);
      expect(cleared.commissionPercent, 60);
      expect(cleared.archivedAt, DateTime(2026, 9));
    });
  });
}
