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

    testWidgets('Should stack the dismissal under the action', (tester) async {
      await pumpDialog(tester, isDestructive: false);

      final confirm = tester.getRect(find.text('Cerrar sesión').last);
      final cancel = tester.getRect(find.text('Quedarme'));

      expect(confirm.bottom, lessThanOrEqualTo(cancel.top));
    });

    testWidgets('Should give the action the full width of the dialog', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: false);

      final action = tester.getRect(find.byType(ElevatedButton));
      final content = tester.getRect(find.text('¿Realmente deseas cerrar sesión?'));

      expect(action.width, greaterThanOrEqualTo(content.width));
    });

    testWidgets('Should leave a destructive action outlined, never filled', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: true);

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('Should fill the action when it destroys nothing', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: false);

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('Should report which answer was tapped', (tester) async {
      await pumpDialog(tester, isDestructive: false);

      await tester.tap(find.text('Cerrar sesión').last);
      await tester.tap(find.text('Quedarme'));

      expect(taps, ['confirm', 'cancel']);
    });

    testWidgets('Should report the same answers when destructive', (
      tester,
    ) async {
      await pumpDialog(tester, isDestructive: true);

      await tester.tap(find.text('Cerrar sesión').last);
      await tester.tap(find.text('Quedarme'));

      expect(taps, ['confirm', 'cancel']);
    });
  });
}
