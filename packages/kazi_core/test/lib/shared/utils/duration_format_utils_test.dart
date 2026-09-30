import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  setUpAll(() => KaziLocalizations.load(const Locale('en')));

  test('under an hour reads in minutes', () {
    expect(DurationFormatUtils.short(const Duration(minutes: 30)), '30 min');
  });

  test('whole hours drop the minutes', () {
    expect(DurationFormatUtils.short(const Duration(hours: 3)), '3 hours');
  });

  test('hours and minutes read together', () {
    expect(
      DurationFormatUtils.short(const Duration(hours: 3, minutes: 20)),
      '3 hours 20 min',
    );
  });

  test('days lead, and an empty part is left out', () {
    expect(
      DurationFormatUtils.short(const Duration(days: 2, minutes: 30)),
      '2 days 30 min',
    );
    expect(DurationFormatUtils.short(const Duration(days: 1)), '1 day');
  });
}
