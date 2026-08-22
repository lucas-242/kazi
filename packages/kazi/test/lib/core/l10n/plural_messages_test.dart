import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// These are the project's first ICU plurals, and a malformed one fails at
/// *generation* time rather than compile time — so a broken pattern reaches
/// runtime as a string that silently never varies. Pinning the distinct forms
/// is what turns that into a red test.
void main() {
  setUp(() async {
    await KaziLocalizations.load(const Locale.fromSubtags(languageCode: 'en'));
  });

  group('cycleClosesIn', () {
    test(
      'Should read the explicit zero and one cases, not the plural rule',
      () {
        // English has no CLDR "zero" category and treats 1 as "one", so these
        // only resolve if `useExplicitNumberCases` is honouring `=0` and `=1`.
        expect(KaziLocalizations.current.cycleClosesIn(0), 'closes today');
        expect(KaziLocalizations.current.cycleClosesIn(1), 'closes tomorrow');
      },
    );

    test('Should interpolate the count in the general case', () {
      expect(KaziLocalizations.current.cycleClosesIn(22), 'closes in 22 days');
    });

    test('Should give each case a distinct string', () {
      final rendered = <String>{
        KaziLocalizations.current.cycleClosesIn(0),
        KaziLocalizations.current.cycleClosesIn(1),
        KaziLocalizations.current.cycleClosesIn(2),
      };

      expect(rendered, hasLength(3));
    });
  });

  group('Translations', () {
    test('Should resolve the plural in every supported locale', () async {
      for (final locale in ['pt', 'es']) {
        await KaziLocalizations.load(Locale.fromSubtags(languageCode: locale));

        final rendered = <String>{
          KaziLocalizations.current.cycleClosesIn(0),
          KaziLocalizations.current.cycleClosesIn(1),
          KaziLocalizations.current.cycleClosesIn(2),
        };

        expect(rendered, hasLength(3), reason: 'locale $locale');
        expect(
          KaziLocalizations.current.cycleClosesIn(22),
          contains('22'),
          reason: 'locale $locale',
        );
      }
    });
  });
}
