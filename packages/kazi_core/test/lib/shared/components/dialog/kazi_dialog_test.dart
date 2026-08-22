import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  group('KaziDialog actions', () {
    late List<String> taps;

    setUp(() => taps = []);

    Future<void> pumpDialog(
      WidgetTester tester, {
      required bool isDestructive,
    }) async {
      // A narrow phone: the width the two buttons have to share is what used
      // to push them onto separate lines.
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: KaziThemeSettings.light(),
          localizationsDelegates: const [KaziLocalizations.delegate],
          supportedLocales: KaziLocalizations.delegate.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => KaziDialog(
                  onConfirm: () => taps.add('confirm'),
                  onCancel: () => taps.add('cancel'),
                  title: 'Cerrar sesión',
                  message: '¿Realmente deseas cerrar sesión?',
                  confirmText: 'Cerrar sesión',
                  cancelText: 'Quedarme',
                  isDestructive: isDestructive,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('Should keep both buttons side by side and the same size', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: true);

      final outlined = tester.getRect(find.byType(OutlinedButton));
      final filled = tester.getRect(find.byType(ElevatedButton));

      expect(outlined.right, lessThanOrEqualTo(filled.left));
      expect(outlined.width, closeTo(filled.width, 0.1));
      expect(outlined.height, closeTo(filled.height, 0.1));
    });

    testWidgets('Should confirm from the outlined button when destructive', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: true);

      await tester.tap(find.byType(OutlinedButton));
      await tester.tap(find.byType(ElevatedButton));

      expect(taps, ['confirm', 'cancel']);
    });

    testWidgets('Should confirm from the filled button otherwise', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: false);

      await tester.tap(find.byType(OutlinedButton));
      await tester.tap(find.byType(ElevatedButton));

      expect(taps, ['cancel', 'confirm']);
    });
  });
}
