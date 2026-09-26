import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  group('KaziNavigator.showDialog', () {
    testWidgets('Should show the dialog instead of calling itself', (
      tester,
    ) async {
      late BuildContext pageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              pageContext = context;
              return const Scaffold();
            },
          ),
        ),
      );

      KaziNavigator.showDialog<void>(
        context: pageContext,
        builder: (_) => const AlertDialog(content: Text('diálogo')),
      );
      await tester.pumpAndSettle();

      expect(find.text('diálogo'), findsOneWidget);
    });
  });
}
