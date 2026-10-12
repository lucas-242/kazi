import 'package:equatable/equatable.dart';

/// A wall-clock time of day, to the minute. The domain's own type, so the
/// model does not reach into Flutter for `TimeOfDay`.
class ClockTime extends Equatable implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  static const int minutesPerDay = 24 * 60;

  /// Reads a stored minute-of-day. Anything outside 0–1439, or not a number,
  /// reads as no time at all rather than wrapping onto another hour.
  static ClockTime? fromMinutes(Object? minutes) {
    if (minutes is! num) return null;
    final value = minutes.toInt();
    if (value < 0 || value >= minutesPerDay) return null;
    return ClockTime(value ~/ 60, value % 60);
  }

  final int hour;
  final int minute;

  int get inMinutes => hour * 60 + minute;

  /// This time on [day]'s calendar date, in local time.
  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(ClockTime other) => inMinutes.compareTo(other.inMinutes);

  @override
  List<Object?> get props => [hour, minute];
}
