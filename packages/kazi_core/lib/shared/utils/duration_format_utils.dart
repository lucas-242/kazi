import 'package:kazi_core/shared/l10n/generated/l10n.dart';

abstract class DurationFormatUtils {
  /// A length of time as the app writes it: "30 min", "1 hour",
  /// "3 hours 20 min", "2 days 4 hours". Zero parts are left out and seconds
  /// are dropped — nothing the app schedules is that precise.
  static String short(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final l10n = KaziLocalizations.current;

    final parts = [
      if (days > 0) l10n.durationDays(days),
      if (hours > 0) l10n.durationHours(hours),
      if (minutes > 0 || duration.inMinutes == 0) l10n.durationMinutes(minutes),
    ];
    return parts.join(' ');
  }
}
