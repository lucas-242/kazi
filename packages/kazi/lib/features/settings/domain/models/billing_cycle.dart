import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/date_range.dart';
import 'package:kazi_core/kazi_core.dart';

/// How often the user gets paid. Persisted as the discriminator of the
/// [BillingCycle] hierarchy, and the only part of it the settings UI enumerates.
enum BillingCycleType { monthly, fortnightly, weekly }

/// The window the home reports on: the stretch of work that one payment covers.
///
/// The anchor is **the payday**, not the start of the window — "o salão me paga
/// dia 5" is the sentence the user can answer. So a cycle *ends* on its anchor
/// and starts the day after the previous one: anchored to the 5th, August's
/// window runs 6 Aug → 5 Sep.
///
/// ## Date arithmetic in this file
///
/// Every boundary is built with the `DateTime(y, m, d)` constructor, which
/// normalises out-of-range components against the local calendar
/// (`DateTime(2026, 8, 32)` is 1 Sep 2026) and can never name a local time that
/// does not exist. **No `Duration` and no `copyWith` below** — adding
/// `Duration(days: 1)` adds exact hours, so crossing a daylight-saving boundary
/// shifts the wall clock and lands on the wrong calendar day, and
/// `copyWith(hour: 0)` on a day that springs forward at midnight targets an
/// instant with no local representation. Cuba, Chile and Paraguay are all
/// [SupportedCurrency] countries, and Cuba springs forward at 00:00.
sealed class BillingCycle extends Equatable {
  const BillingCycle();

  /// Restores a cycle from the user document. Never throws and never rejects:
  /// a corrupt or unknown value degrades to [monthlyDefault], because a user
  /// who cannot read their own totals is worse off than one reading them over
  /// the wrong window.
  factory BillingCycle.fromMap(Map<String, dynamic> data) {
    final rawAnchor = data[anchorField];
    final anchor = rawAnchor is num ? rawAnchor.toInt() : null;

    switch (data[typeField]) {
      case 'monthly':
        return MonthlyCycle(anchorDay: anchor ?? lastDayAnchor);
      case 'fortnightly':
        return FortnightlyCycle(anchorDay: anchor ?? lastDayAnchor);
      case 'weekly':
        return WeeklyCycle(anchorWeekday: anchor ?? DateTime.friday);
      default:
        return monthlyDefault;
    }
  }

  static const String typeField = 'billingCycleType';
  static const String anchorField = 'billingCycleAnchorDay';

  /// Anchoring a monthly cycle to the 31st means "the last day of the month",
  /// because [_monthDay] clamps to the month's length. That makes the default
  /// *exactly* the calendar month, so users who never open the setting keep the
  /// window the app used before cycles existed — no migration, no backfill.
  static const BillingCycle monthlyDefault = MonthlyCycle(
    anchorDay: lastDayAnchor,
  );

  /// The anchor value that means "the last day of the month" rather than a
  /// literal 31st — no month has more than 31 days, so this always clamps via
  /// [_monthDay] to whatever the month's actual last day is (28, 29 or 30).
  /// The UI must special-case this value rather than displaying it as a day
  /// number.
  static const int lastDayAnchor = 31;

  BillingCycleType get type;

  /// The day the current window is paid out — the first anchor on or after
  /// [now]. On the payday itself this returns that same day.
  DateTime closesOn(DateTime now);

  /// The window [now] falls into.
  DateRange currentCycle(DateTime now);

  /// Whole days from [now] until the payday. Zero on the payday itself.
  int daysUntilClose(DateTime now) => closesOn(now).calculateDifference(now);

  Map<String, dynamic> toMap();

  /// [day] of [month], clamped to the month's length — so the 31st is 28 or 29
  /// in February and 30 in April. `month` may be 0 or 13; the constructor rolls
  /// it into the neighbouring year.
  static DateTime _monthDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day < lastDay ? day : lastDay);
  }

  /// [date] with the time stripped, so comparisons are by calendar day.
  static DateTime _dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// A range that opens the day after [previousClose] and ends with [close].
  static DateRange _between(DateTime previousClose, DateTime close) =>
      DateRange(
        start: DateTime(
          previousClose.year,
          previousClose.month,
          previousClose.day + 1,
        ),
        end: DateTime(close.year, close.month, close.day, 23, 59, 59),
      );

  /// The first monthly anchor on or after [today].
  static DateTime _monthlyCloseOnOrAfter(DateTime today, int anchorDay) {
    final thisMonth = _monthDay(today.year, today.month, anchorDay);
    if (!thisMonth.isBefore(today)) return thisMonth;
    return _monthDay(today.year, today.month + 1, anchorDay);
  }
}

/// One payday a month.
final class MonthlyCycle extends BillingCycle {
  const MonthlyCycle({required this.anchorDay});

  /// Day of the month the user is paid, 1–31. Values past the month's length
  /// mean "the last day" — see [BillingCycle._monthDay].
  final int anchorDay;

  @override
  BillingCycleType get type => BillingCycleType.monthly;

  @override
  DateTime closesOn(DateTime now) =>
      BillingCycle._monthlyCloseOnOrAfter(BillingCycle._dayOf(now), anchorDay);

  @override
  DateRange currentCycle(DateTime now) {
    final close = closesOn(now);
    final previousClose = BillingCycle._monthDay(
      close.year,
      close.month - 1,
      anchorDay,
    );
    return BillingCycle._between(previousClose, close);
  }

  @override
  Map<String, dynamic> toMap() => {
    BillingCycle.typeField: type.name,
    BillingCycle.anchorField: anchorDay,
  };

  @override
  List<Object?> get props => [type, anchorDay];
}

/// Two paydays a month: the monthly anchor, plus the midpoint between it and
/// the previous one.
///
/// Deriving the second payday from the monthly sequence — rather than as
/// "anchor" and "anchor + 15" — is what keeps the windows gap-free and in order
/// for every anchor. Anchored to the 5th it yields 5 and 20, the case that
/// motivated configurable cycles; anchored to the 25th it yields 25 and 10 of
/// the next month, where the naive formulation would drift.
final class FortnightlyCycle extends BillingCycle {
  const FortnightlyCycle({required this.anchorDay});

  /// Day of the month of the *later* of the two paydays, 1–31.
  final int anchorDay;

  @override
  BillingCycleType get type => BillingCycleType.fortnightly;

  @override
  DateTime closesOn(DateTime now) => _boundsOf(BillingCycle._dayOf(now)).close;

  @override
  DateRange currentCycle(DateTime now) {
    final bounds = _boundsOf(BillingCycle._dayOf(now));
    return BillingCycle._between(bounds.previousClose, bounds.close);
  }

  ({DateTime previousClose, DateTime close}) _boundsOf(DateTime today) {
    final monthlyClose = BillingCycle._monthlyCloseOnOrAfter(today, anchorDay);
    final monthlyPrevious = BillingCycle._monthDay(
      monthlyClose.year,
      monthlyClose.month - 1,
      anchorDay,
    );
    final midpoint = _midpoint(monthlyPrevious, monthlyClose);

    return today.isAfter(midpoint)
        ? (previousClose: midpoint, close: monthlyClose)
        : (previousClose: monthlyPrevious, close: midpoint);
  }

  /// Halfway between two consecutive monthly paydays, rounded down. Months are
  /// 28–31 days, so the two halves differ by at most a day.
  static DateTime _midpoint(DateTime from, DateTime to) => DateTime(
    from.year,
    from.month,
    from.day + to.calculateDifference(from) ~/ 2,
  );

  @override
  Map<String, dynamic> toMap() => {
    BillingCycle.typeField: type.name,
    BillingCycle.anchorField: anchorDay,
  };

  @override
  List<Object?> get props => [type, anchorDay];
}

/// One payday a week, on a fixed weekday.
final class WeeklyCycle extends BillingCycle {
  const WeeklyCycle({required this.anchorWeekday});

  /// The weekday the user is paid, [DateTime.monday]–[DateTime.sunday].
  final int anchorWeekday;

  @override
  BillingCycleType get type => BillingCycleType.weekly;

  @override
  DateTime closesOn(DateTime now) {
    final today = BillingCycle._dayOf(now);
    final daysAhead = (anchorWeekday - today.weekday) % DateTime.daysPerWeek;
    return DateTime(today.year, today.month, today.day + daysAhead);
  }

  @override
  DateRange currentCycle(DateTime now) {
    final close = closesOn(now);
    return BillingCycle._between(
      DateTime(close.year, close.month, close.day - DateTime.daysPerWeek),
      close,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    BillingCycle.typeField: type.name,
    BillingCycle.anchorField: anchorWeekday,
  };

  @override
  List<Object?> get props => [type, anchorWeekday];
}
