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
