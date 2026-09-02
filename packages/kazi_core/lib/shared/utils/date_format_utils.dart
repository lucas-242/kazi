import 'package:intl/intl.dart';

abstract class DateFormatUtils {
  /// A day as the app writes it: "9 de ago", and "9 de ago de 2024" once the
  /// year stops being obvious.
  ///
  /// The year is dropped inside the current one because almost everything the
  /// app shows a date for happened this year, and printing it every time makes
  /// the one entry from last year look like the rest.
  static String day(DateTime date, {String? locale, DateTime? now}) {
    final reference = now ?? DateTime.now();
    final format = date.year == reference.year
        ? DateFormat.MMMd(locale)
        : DateFormat.yMMMd(locale);

    return format.format(date);
  }
}
