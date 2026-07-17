import 'dart:ui';

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  DateTime get firstHourOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  DateTime get lastHourOfDay => copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 0,
        microsecond: 0,
      );

  /// Find the next [weekday]. [weekday] can 0 for Sunday, 1 for Monday, etc. up to 7 for Sunday.
  DateTime nextWeekday(int weekday) {
    final result =
        add(Duration(days: (weekday - this.weekday) % DateTime.daysPerWeek));

    return result;
  }

  /// Find the last [weekday]. [weekday] can be 0 for Sunday, 1 for Monday, etc. up to 7 for Sunday.
  DateTime lastWeekday(int weekday) =>
      DateTime(year, month, day - (this.weekday - weekday) % 7);

  /// Returns the difference (in full days) between the provided [date]
  int calculateDifference(DateTime date) => DateTime(year, month, day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;

  ///Formats date to yyyy-MM-dd formmat using the [locale]
  String format([Locale? locale]) => DateFormat.yMd(locale).format(this);

  ///Formats date to MM-EE-dd HH:mm formmat using the [locale]
  String formatWithHour([Locale? locale]) =>
      DateFormat.MEd(locale).add_Hm().format(this);

  ///Formats date to HH:mm formmat using the [locale]
  String formatHour([Locale? locale]) => DateFormat.Hm(locale).format(this);

  ///Formats date to day abbreviated_month abbreviated_weekday format using the [locale]
  String formatDayMonthWeekday([Locale? locale]) {
    final day = this.day;
    final month = DateFormat.MMM(locale).format(this);
    final weekday = DateFormat.E(locale).format(this);
    return '$day $month, $weekday';
  }
}
