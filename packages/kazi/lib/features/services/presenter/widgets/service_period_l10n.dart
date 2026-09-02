import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// One preset in the user's words. [start] is the first day of the window the
/// preset resolves to, which is what lets the month presets name their month
/// instead of saying "this one".
String fastSearchLabel(
  FastSearch search,
  DateTime start, [
  DateTime? end,
]) {
  final l10n = KaziLocalizations.current;

  return switch (search) {
    FastSearch.today => l10n.today,
    FastSearch.week => l10n.week,
    FastSearch.fortnight => l10n.fortnight,
    // Named, not relative: "Agosto" says which month is on screen, while
    // "Este mês" only says it is the current one.
    FastSearch.month || FastSearch.lastMonth => start.monthName(),
    // A hand-picked range has no name, so it says its dates.
    FastSearch.custom when end != null =>
      '${DateFormat.yMd().format(start).normalizeDate()} - '
          '${DateFormat.yMd().format(end).normalizeDate()}',
    FastSearch.custom => l10n.pickDates,
  };
}

/// The window in the user's words, shared by the period chip and the header
/// card above the list — the two must never disagree about what is on screen.
extension ServicePeriodL10n on ServiceLandingState {
  String get periodLabel => fastSearchLabel(fastSearch, startDate, endDate);
}
