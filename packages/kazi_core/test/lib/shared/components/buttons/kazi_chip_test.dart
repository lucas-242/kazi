import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, {VoidCallback? onTap}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: KaziThemeSettings.light(),
          home: Scaffold(
            body: KaziChip(label: 'Cancelled', onTap: onTap),
          ),
        ),
      );

  testWidgets('an enabled chip answers taps', (tester) async {
    var taps = 0;
    await pumpChip(tester, onTap: () => taps++);

    await tester.tap(find.text('Cancelled'));

    expect(taps, 1);
  });

  testWidgets('a chip without onTap is dimmed and announced as disabled', (
    tester,
  ) async {
    await pumpChip(tester);

    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Cancelled'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(1));
    expect(
      tester.getSemantics(find.byType(KaziChip)),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
    );
  });
}
