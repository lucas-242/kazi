import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The five steps of the home trail.
///
/// They lead to a habit, not to knowledge. Each one is here because it marks a
/// behaviour shared by the people who stay — which is also why none of them is
/// "read about feature X".
enum ChecklistStep {
  /// Without types nothing calculates. It is the blocker that stalls most
  /// people today, and the setup arrives with it already done.
  catalog('catalog'),

  /// The first real number: where the store's promise is kept.
  firstService('first_service'),

  /// One record is curiosity; three is a routine starting.
  threeServices('three_services'),

  /// Closes the "earned → paid" loop and gives the number at the top of the
  /// home its meaning.
  markReceived('mark_received'),

  /// Shows that the app accumulates value over time — the argument against
  /// uninstalling.
  seeSummary('see_summary');

  const ChecklistStep(this.key);

  /// Stable identifier for the ones that are recorded rather than derived, and
  /// for analytics.
  final String key;

  String get label => switch (this) {
    ChecklistStep.catalog => KaziLocalizations.current.checklistBuildCatalog,
    ChecklistStep.firstService =>
      KaziLocalizations.current.checklistFirstService,
    ChecklistStep.threeServices =>
      KaziLocalizations.current.checklistThreeServices,
    ChecklistStep.markReceived =>
      KaziLocalizations.current.checklistMarkReceived,
    ChecklistStep.seeSummary => KaziLocalizations.current.checklistSeeSummary,
  };

  /// Whether completion is an event we have to record, rather than something
  /// the user's own data already answers.
  ///
  /// Counting services is free and cannot drift. "Has ever marked one as
  /// received" and "has opened the summary" have no cheap query behind them,
  /// so they are stamped when they happen.
  bool get isRecorded =>
      this == ChecklistStep.markReceived || this == ChecklistStep.seeSummary;
}
