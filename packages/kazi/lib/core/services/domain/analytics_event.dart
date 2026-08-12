/// snake_case and under 40 characters, which is what Firebase Analytics
/// accepts.
enum AnalyticsEvent {
  /// The guided setup opened. Denominator for every step-level drop-off.
  setupStarted('setup_started'),

  /// A setup step was shown. Parameter: `step`.
  setupStepViewed('setup_step_viewed'),

  /// The user left through the close button. Parameter: `step` — the screen
  /// concentrating the abandonment is the one asking too much.
  setupExited('setup_exited'),

  /// The setup finished. Parameters: `seconds` (login to first number, whose
  /// target is under two minutes), `seeded_types`, `registered_service`.
  setupCompleted('setup_completed'),

  /// A home-checklist step was completed. Parameter: `step`.
  checklistStepCompleted('checklist_step_completed'),

  /// A contextual hint was acknowledged. Parameter: `hint`.
  hintDismissed('hint_dismissed');

  const AnalyticsEvent(this.name);

  final String name;
}
