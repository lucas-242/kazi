import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  Future<void> show(WidgetTester tester, String message) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: KaziThemeSettings.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => KaziSnackbar.show(context, message),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
  }

  Future<void> dismiss(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 5));

  /// The paragraph is clipped when the box it was given is shorter than the
  /// height its lines need at that width.
  void expectFullyVisible(WidgetTester tester, String message) {
    final paragraph = tester.renderObject<RenderParagraph>(find.text(message));
    final needed = paragraph.getMaxIntrinsicHeight(paragraph.size.width);
    expect(paragraph.size.height, greaterThanOrEqualTo(needed));
  }

  testWidgets('Should grow to fit a message that wraps', (tester) async {
    const message =
        'Não foi possível excluir sua conta. Tente de novo em alguns '
        'minutos, ou fale com a gente se continuar acontecendo.';
    await show(tester, message);

    expectFullyVisible(tester, message);

    await dismiss(tester);
  });

  testWidgets('Should keep its height for a one-line message', (tester) async {
    await show(tester, 'Salvo');

    expectFullyVisible(tester, 'Salvo');
    final box = find.ancestor(
      of: find.text('Salvo'),
      matching: find.byType(Material),
    );
    expect(tester.getSize(box.first).height, 50);

    await dismiss(tester);
  });
}
