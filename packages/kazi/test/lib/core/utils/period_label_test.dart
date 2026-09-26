import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/period_label.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../utils/test_helper.dart';

void main() {
  // `en` alone carries no date symbols; `en_US` is the one intl ships built in.
  setUpAll(() async {
    await TestHelper.loadAppLocalizations();
    Intl.defaultLocale = 'en_US';
  });

  final today = DateTime(2026, 9, 21);

  group('periodRangeLabel', () {
    test('names a month of the current year without its year', () {
      final label = periodRangeLabel(
        DateTime(2026, 9),
        DateTime(2026, 9, 30),
        today: today,
      );

      expect(label, 'September');
    });

    test('spells the year out for a month of another year', () {
      final label = periodRangeLabel(
        DateTime(2025, 9),
        DateTime(2025, 9, 30),
        today: today,
      );

      expect(label, 'September 2025');
    });

    test('names a whole year by its year alone', () {
      final label = periodRangeLabel(
        DateTime(2026),
        DateTime(2026, 12, 31),
        today: today,
      );

      expect(label, '2026');
    });

    test('says the dates when the range is not a whole month', () {
      final label = periodRangeLabel(
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 30),
        today: today,
      );

      expect(label, 'From 09/02/2026 to 09/30/2026');
    });
  });
}
