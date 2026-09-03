import 'package:flutter/widgets.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart';

/// The user-facing name of a pay cycle.
///
/// Shared between the cycle page, which offers the three of them, and the menu
/// row, which reports the one in force — so the two can never drift into
/// calling the same cycle by different names.
extension BillingCycleTypeL10n on BillingCycleType {
  String get label => switch (this) {
    BillingCycleType.monthly => KaziLocalizations.current.billingCycleMonthly,
    BillingCycleType.fortnightly =>
      KaziLocalizations.current.billingCycleFortnightly,
    BillingCycleType.weekly => KaziLocalizations.current.billingCycleWeekly,
  };
}

/// The payday itself — "Dia 5" for a monthly/fortnightly anchor, the weekday
/// name for a weekly one. Shared for the same reason as [BillingCycleTypeL10n].
extension BillingCycleL10n on BillingCycle {
  String anchorLabel(BuildContext context) => switch (this) {
    MonthlyCycle(:final anchorDay) => KaziLocalizations.current.billingCycleDay(
      anchorDay,
    ),
    FortnightlyCycle(:final anchorDay) =>
      KaziLocalizations.current.billingCycleDay(anchorDay),
    WeeklyCycle(:final anchorWeekday) => weekdayLabel(context, anchorWeekday),
  };
}

/// The localized name of [weekday] ([DateTime.monday]–[DateTime.sunday]).
String weekdayLabel(BuildContext context, int weekday) {
  final locale = Localizations.localeOf(context).toString();
  // Any Monday: adding weekday - 1 walks to the wanted day of that week.
  final reference = DateTime(2024, 1, weekday);
  return DateFormat.EEEE(locale).format(reference);
}
