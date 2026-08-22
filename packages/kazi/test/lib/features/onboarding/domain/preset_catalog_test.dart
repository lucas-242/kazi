import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/onboarding/domain/preset_catalog.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../../../../utils/test_helper.dart';

void main() {
  // Preset labels resolve through `KaziLocalizations.current`, and search
  // matches against them.
  setUpAll(TestHelper.loadAppLocalizations);

  group('prices', () {
    test('Should price presets in BRL', () {
      for (final preset in PresetCatalog.all) {
        for (final service in preset.services) {
          expect(
            preset.priceFor(service, SupportedCurrency.brl),
            service.brlPrice,
          );
        }
      }
    });

    test('Should leave presets unpriced outside BRL', () {
      // Converting R$ 180 into dollars would put a meaningless number on the
      // second screen and cost the trust the whole app is selling.
      for (final currency in SupportedCurrency.values) {
        if (currency == SupportedCurrency.brl) continue;
        for (final preset in PresetCatalog.all) {
          for (final service in preset.services) {
            expect(
              preset.priceFor(service, currency),
              isNull,
              reason: '${preset.key} priced in ${currency.isoCode}',
            );
          }
        }
      }
    });

    test('Should give every preset a positive reference price', () {
      for (final preset in PresetCatalog.all) {
        for (final service in preset.services) {
          expect(service.brlPrice, greaterThan(0));
        }
      }
    });
  });

  group('kits', () {
    test('Should keep every kit within the free service-type ceiling', () {
      // A seeded catalog must never put a free user over their own limit,
      // which is what `FreemiumLimits._newFree.maxCatalogItems` allows.
      for (final preset in PresetCatalog.all) {
        final preSelected = preset.services.where((s) => s.preSelected).length;
        expect(preSelected, lessThanOrEqualTo(10));
        expect(preSelected, greaterThan(0));
      }
    });

    test('Should give every kit a unique key', () {
      final keys = PresetCatalog.all.map((preset) => preset.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('Should never collide with the typed-profession marker', () {
      expect(
        PresetCatalog.all.map((preset) => preset.key),
        isNot(contains(PresetCatalog.otherKey)),
      );
    });

    test('Should offer a commission between 1 and 100 per kit', () {
      for (final preset in PresetCatalog.all) {
        expect(preset.defaultCommissionPercent, greaterThan(0));
        expect(preset.defaultCommissionPercent, lessThanOrEqualTo(100));
      }
    });

    test('Should feature kits that exist in the catalog', () {
      for (final preset in PresetCatalog.featured) {
        expect(PresetCatalog.byKey(preset.key), isNotNull);
      }
    });
  });

  group('search', () {
    test('Should match a synonym', () {
      final matches = PresetCatalog.search('unhas');
      expect(matches.map((preset) => preset.key), contains('manicure'));
    });

    test('Should ignore accents and case', () {
      // "depilacao" has to find "depilação", or the typed path sends someone
      // who has a kit into a blank form.
      expect(PresetCatalog.search('DEPILACAO'), isNotEmpty);
      expect(PresetCatalog.search('estetica'), isNotEmpty);
    });

    test('Should return nothing for an empty query', () {
      expect(PresetCatalog.search(''), isEmpty);
      expect(PresetCatalog.search('   '), isEmpty);
    });

    test('Should return nothing when no kit matches', () {
      expect(PresetCatalog.search('astronauta'), isEmpty);
    });
  });
}
