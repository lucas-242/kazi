import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/date_range.dart';

void main() {
  final range = DateRange(
    start: DateTime(2026, 8, 6),
    end: DateTime(2026, 9, 5, 23, 59, 59),
  );

  group('contains', () {
    test('Should include a date inside the range', () {
      expect(range.contains(DateTime(2026, 8, 20)), isTrue);
    });

    test('Should include both ends', () {
      expect(range.contains(range.start), isTrue);
      expect(range.contains(range.end), isTrue);
    });

    test('Should include the last instant of the closing day', () {
      expect(range.contains(DateTime(2026, 9, 5, 23, 59, 59)), isTrue);
    });

    test('Should exclude dates outside the range', () {
      expect(range.contains(DateTime(2026, 8, 5, 23, 59, 59)), isFalse);
      expect(range.contains(DateTime(2026, 9, 6)), isFalse);
    });
  });

  test('Should compare by value', () {
    expect(
      range,
      DateRange(
        start: DateTime(2026, 8, 6),
        end: DateTime(2026, 9, 5, 23, 59, 59),
      ),
    );
  });
}
