import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The window in the user's words, shared by the period chip and the header
/// card above the list — the two must never disagree about what is on screen.
extension ServicePeriodL10n on ServiceLandingState {
  String get periodLabel {
    final l10n = KaziLocalizations.current;

    return switch (fastSearch) {
      FastSearch.today => l10n.today,
      FastSearch.week => l10n.week,
      FastSearch.fortnight => l10n.fortnight,
      FastSearch.month => l10n.month,
      FastSearch.lastMonth => l10n.lastMonth,
      // A hand-picked range has no name, so it says its dates.
      FastSearch.custom =>
        '${DateFormat.yMd().format(startDate).normalizeDate()} - '
            '${DateFormat.yMd().format(endDate).normalizeDate()}',
    };
  }
}
