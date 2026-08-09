import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  group('KaziHexColor', () {
    test('round-trips a colour', () {
      const color = Color(0xFF2F6FEB);

      final encoded = KaziHexColor.encode(color);

      expect(encoded, 'FF2F6FEB');
      expect(KaziHexColor.tryParse(encoded), color);
    });

    test('encodes with the leading zeros kept', () {
      expect(KaziHexColor.encode(const Color(0x00000000)), '00000000');
    });

    test('reads unset and corrupt values as no colour', () {
      expect(KaziHexColor.tryParse(null), isNull);
      expect(KaziHexColor.tryParse(''), isNull);
      expect(KaziHexColor.tryParse('2F6FEB'), isNull);
      expect(KaziHexColor.tryParse('#FF2F6FEB'), isNull);
      expect(KaziHexColor.tryParse('not-a-hex'), isNull);
    });
  });
}
