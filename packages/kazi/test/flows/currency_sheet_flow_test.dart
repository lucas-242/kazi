import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/settings/presenter/widgets/currency_bottom_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// The currency sheet is the only sheet in the app that pairs a text field with
/// a long list, so it is the only one the keyboard can break: the sheet is
/// anchored to the bottom of the screen, and everything the keyboard covers is
/// unreachable rather than merely hidden.
void main() {
  /// Height of the fake keyboard, in logical pixels. The harness pins the
  /// surface to 420x950 at a device pixel ratio of 1.
  const keyboardHeight = 500.0;
  const screenHeight = 950.0;

  Future<TestAppHarness> openTheSheet(WidgetTester tester) async {
    final app = TestAppHarness();
    await app.pump(tester);
    await tester.tap(find.byIcon(Icons.tune));
    await settle(tester);
    await tester.tap(find.text(KaziLocalizations.current.defaultCurrency));
    await settle(tester);
    return app;
  }

  Future<void> raiseTheKeyboard(WidgetTester tester) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
    addTearDown(tester.view.resetViewInsets);
    await settle(tester);
  }

  testWidgets('the sheet does not overflow when the keyboard comes up', (
    tester,
  ) async {
    await openTheSheet(tester);
    await raiseTheKeyboard(tester);

    expect(find.byType(CurrencyBottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The bug this pins: capping the sheet against the full screen height left
  // the tail of the list rendered underneath the keyboard, where no amount of
  // scrolling reaches it.
  testWidgets('the list stays above the keyboard, and scrolls', (tester) async {
    await openTheSheet(tester);
    await raiseTheKeyboard(tester);

    final list = find.descendant(
      of: find.byType(CurrencyBottomSheet),
      matching: find.byType(ListView),
    );

    expect(
      tester.getBottomLeft(list).dy,
      lessThanOrEqualTo(screenHeight - keyboardHeight),
    );

    final firstRow = tester.getTopLeft(find.byType(OptionTile).first).dy;
    await tester.drag(list, const Offset(0, -120));
    await settle(tester);

    expect(tester.getTopLeft(find.byType(OptionTile).first).dy, lessThan(firstRow));
  });
}
