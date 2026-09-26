import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The contextual hints, each shown once, where the function actually lives.
///
/// They cover what is not urgent at minute zero and would only bloat the
/// setup. Every one is learned by doing, on the user's own data.
enum OnboardingHint {
  /// On the first return to the home after the setup.
  fab('hint_fab_seen'),

  /// On opening the first service's details.
  markReceived('hint_received_seen'),

  /// On the services tab, once there is a history worth filtering.
  filters('hint_filters_seen'),

  /// On the summary, once there is something to summarize.
  summary('hint_summary_seen');

  const OnboardingHint(this.storageKey);

  /// Local storage, not the user document. Re-seeing a hint on a new device is
  /// harmless, and it saves a Firestore write per bubble.
  final String storageKey;

  String get title => switch (this) {
    OnboardingHint.fab => KaziLocalizations.current.hintFabTitle,
    OnboardingHint.markReceived =>
      KaziLocalizations.current.hintReceivedTitle,
    OnboardingHint.filters => KaziLocalizations.current.hintFiltersTitle,
    OnboardingHint.summary => KaziLocalizations.current.hintSummaryTitle,
  };

  String get message => switch (this) {
    OnboardingHint.fab => KaziLocalizations.current.hintFabBody,
    OnboardingHint.markReceived => KaziLocalizations.current.hintReceivedBody,
    OnboardingHint.filters => KaziLocalizations.current.hintFiltersBody,
    OnboardingHint.summary => KaziLocalizations.current.hintSummaryBody,
  };
}
