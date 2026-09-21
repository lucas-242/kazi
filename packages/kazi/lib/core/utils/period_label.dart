import 'package:kazi_core/kazi_core.dart';

/// The exact window in the user's words: a concrete month or year name when
/// [start]..[end] spans exactly one, the single date when both fall on the
/// same day, and "de X até Y" otherwise — never a preset's generic name
/// ("Semana", "Quinzena"), which says nothing about which days are on
/// screen. Shared by every screen that has to say precisely what period it
/// is reporting on (Services' header, the home's own cycle label).
///
/// A month in the current year is named alone ("Setembro"); the year is
/// spelled out only when it is not [today]'s, which is the case where the
/// month name by itself would be read as this year's. [today] defaults to
/// the current date and exists so a test can pin it.
String periodRangeLabel(DateTime start, DateTime end, {DateTime? today}) {
  if (_isFullYear(start, end)) return '${start.year}';
  if (_isFullMonth(start, end)) {
    final currentYear = (today ?? DateTime.now()).year;
    return start.year == currentYear
        ? start.monthName()
        : '${start.monthName()} ${start.year}';
  }

  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  if (startDay == endDay) {
    return DateFormat.yMd().format(start).normalizeDate();
  }

  return KaziLocalizations.current.fromTo(
    DateFormat.yMd().format(start).normalizeDate(),
    DateFormat.yMd().format(end).normalizeDate(),
  );
}

bool _isFullMonth(DateTime start, DateTime end) {
  final lastDayOfMonth = DateTime(start.year, start.month + 1, 0).day;
  return start.year == end.year &&
      start.month == end.month &&
      start.day == 1 &&
      end.day == lastDayOfMonth;
}

bool _isFullYear(DateTime start, DateTime end) =>
    start.year == end.year &&
    start.month == 1 &&
    start.day == 1 &&
    end.month == 12 &&
    end.day == 31;
