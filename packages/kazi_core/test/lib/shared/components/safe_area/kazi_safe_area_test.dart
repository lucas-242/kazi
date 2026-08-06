import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  group('KaziSafeArea isLoading', () {
    late int appBarTaps;
    late int bodyTaps;

    setUp(() {
      appBarTaps = 0;
      bodyTaps = 0;
    });

    Future<void> pumpSafeArea(WidgetTester tester, {required bool isLoading}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => appBarTaps++,
                ),
              ],
            ),
            body: KaziSafeArea(
              isLoading: isLoading,
              isScrollView: false,
              child: GestureDetector(
                onTap: () => bodyTaps++,
                child: const SizedBox.expand(child: Text('conteúdo')),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Should block taps on the body and on the app bar', (
      tester,
    ) async {
      await pumpSafeArea(tester, isLoading: true);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add), warnIfMissed: false);
      await tester.tap(find.text('conteúdo'), warnIfMissed: false);
      await tester.pump();

      expect(appBarTaps, 0);
      expect(bodyTaps, 0);
    });

    testWidgets('Should keep the content visible behind the overlay', (
      tester,
    ) async {
      await pumpSafeArea(tester, isLoading: true);
      await tester.pump();

      expect(find.text('conteúdo'), findsOneWidget);
    });

    testWidgets('Should not block anything when it is not loading', (
      tester,
    ) async {
      await pumpSafeArea(tester, isLoading: false);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.text('conteúdo'));
      await tester.pump();

      expect(appBarTaps, 1);
      expect(bodyTaps, 1);
    });
  });
}
