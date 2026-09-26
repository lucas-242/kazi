import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

/// The bar under a given bottom inset, with the shell's four destinations and
/// the docked button.
Future<void> _pump(
  WidgetTester tester, {
  double bottomInset = 0,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: KaziThemeSettings.light(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          padding: EdgeInsets.only(bottom: bottomInset),
          viewPadding: EdgeInsets.only(bottom: bottomInset),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          floatingActionButton: KaziNavBarFab(
            onTap: () {},
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: const KaziNavBarFabLocation(),
          bottomNavigationBar: KaziNavBar(
            selectedIndex: 0,
            onSelected: (_) {},
            items: const [
              KaziNavBarItem(icon: Icons.home, label: 'Início'),
              KaziNavBarItem(icon: Icons.list, label: 'Serviços'),
              KaziNavBarItem(icon: Icons.people, label: 'Clientes'),
              KaziNavBarItem(icon: Icons.settings, label: 'Ajustes'),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The four destinations — not the button's own ink well, which the Scaffold
/// hangs outside the bar.
final _destinations = find.descendant(
  of: find.byType(KaziNavBar),
  matching: find.byType(InkWell),
);

void main() {
  /// A destination's own ink: the icon, the gap and one line of label.
  const ink = KaziSizings.navBarIcon + 3 + 10 * 1.1;

  /// What the bar measures with nothing under it — the ink with
  /// [KaziInsets.xs] above and below.
  const bar = ink + KaziInsets.xs * 2;

  group('Height', () {
    testWidgets('Should give each destination xs above and below its ink', (
      tester,
    ) async {
      await _pump(tester);

      expect(tester.getSize(find.byType(KaziNavBar)).height, bar);
      expect(bar, greaterThanOrEqualTo(KaziSizings.navBarMinHeight));
    });

    testWidgets('Should add the inset exactly once', (tester) async {
      await _pump(tester, bottomInset: 34);

      expect(tester.getSize(find.byType(KaziNavBar)).height, bar + 34);
    });

    testWidgets('Should grow with the text scale instead of clipping', (
      tester,
    ) async {
      await _pump(tester, textScale: 2);

      expect(tester.getSize(find.byType(KaziNavBar)).height, greaterThan(bar));
      expect(tester.takeException(), isNull);
    });
  });

  group('Touch targets', () {
    testWidgets('Should stay at the minimum whatever the inset', (
      tester,
    ) async {
      for (final inset in [0.0, 24.0, 34.0, 48.0]) {
        await _pump(tester, bottomInset: inset);

        expect(_destinations, findsNWidgets(4));
        for (var i = 0; i < 4; i++) {
          final size = tester.getSize(_destinations.at(i));
          expect(size.height, greaterThanOrEqualTo(KaziSizings.minTouchTarget));
          expect(size.width, greaterThanOrEqualTo(KaziSizings.minTouchTarget));
        }
      }
    });

    testWidgets('Should not ink on touch', (tester) async {
      await _pump(tester);

      final ink = tester.widget<InkWell>(_destinations.first);

      expect(ink.splashFactory, NoSplash.splashFactory);
      expect(ink.highlightColor, Colors.transparent);
    });
  });

  group('The docked button', () {
    testWidgets('Should sit in a notch with a gap around it', (tester) async {
      await _pump(tester);

      final bar = tester.widget<BottomAppBar>(find.byType(BottomAppBar));

      expect(bar.shape, isA<CircularNotchedRectangle>());
      // The cut is the button inflated by this, so the margin is the gap —
      // and the gap is a hole onto whatever is behind the bar. See README.md.
      expect(bar.notchMargin, KaziInsets.xs);
    });
  });

  group('Accessibility', () {
    testWidgets('Should name each destination as a button that can be selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);

      expect(
        tester.getSemantics(_destinations.first),
        matchesSemantics(
          label: 'Início',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('Should hold its labels well past the 200% WCAG 1.4.4 asks for', (
      tester,
    ) async {
      await _pump(tester, textScale: 3);

      expect(tester.takeException(), isNull);
    });
  });
}
