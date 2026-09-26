import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

const _category = Color(0xFFE255A1);
const _hairline = Color(0xFF111111);
const _card = Color(0xFFFFFFFF);

/// The rendered card as a pixel reader, so the assertions can name a point on
/// the edge instead of a golden file.
Future<Color Function(int x, int y)> _paint(
  WidgetTester tester,
  KaziCategoryBorder border,
) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          child: SizedBox(
            width: 100,
            height: 60,
            child: Material(
              color: _card,
              shape: border,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
  );

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).last,
  );

  late ByteData bytes;
  late int width;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    width = image.width;
    bytes = (await image.toByteData())!;
  });

  return (x, y) {
    final offset = (y * width + x) * 4;
    return Color.fromARGB(
      bytes.getUint8(offset + 3),
      bytes.getUint8(offset),
      bytes.getUint8(offset + 1),
      bytes.getUint8(offset + 2),
    );
  };
}

void main() {
  const border = KaziCategoryBorder(
    color: _hairline,
    categoryColor: _category,
  );

  testWidgets('paints the leading edge in the category colour', (tester) async {
    final pixel = await _paint(tester, border);

    expect(pixel(1, 30), _category);
  });

  testWidgets('paints the three remaining sides in the hairline colour', (
    tester,
  ) async {
    final pixel = await _paint(tester, border);

    expect(pixel(50, 0), _hairline);
    expect(pixel(50, 59), _hairline);
    expect(pixel(99, 30), _hairline);
  });

  testWidgets('carries the leading colour around the corner', (tester) async {
    final pixel = await _paint(tester, border);

    // The straight run ends at x = categoryWidth; a corner mitred on the ray
    // out of the box's corner keeps the colour well past that, which is the
    // difference between following the curve and being cut off square.
    var reach = 0;
    for (var y = 0; y < 12; y++) {
      for (var x = 0; x < 12; x++) {
        if (pixel(x, y) == _category && x > reach) reach = x;
      }
    }

    expect(reach, greaterThan(3));
  });

  testWidgets('leaves the interior to the surface underneath', (tester) async {
    final pixel = await _paint(tester, border);

    expect(pixel(50, 30), _card);
  });

  testWidgets('falls back to the hairline colour without a category', (
    tester,
  ) async {
    final pixel = await _paint(
      tester,
      const KaziCategoryBorder(color: _hairline, categoryColor: null),
    );

    expect(pixel(1, 30), _hairline);
  });

  test('reserves the leading edge and the hairline as its dimensions', () {
    expect(
      border.dimensions,
      const EdgeInsetsDirectional.only(start: 3, top: 1, end: 1, bottom: 1),
    );
  });
}
