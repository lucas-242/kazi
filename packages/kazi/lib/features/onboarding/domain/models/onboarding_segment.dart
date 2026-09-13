/// Which onboarding treatment an account gets.
///
/// Every account goes through a setup exactly once; what differs is which one.
/// The rules are in `features/onboarding/README.md`.
enum OnboardingSegment {
  /// Setup never completed and no service registered: the full setup.
  fresh,

  /// Setup never completed; services exist, but none dated in the last
  /// month. An account that stopped, so it gets the full setup too.
  dormant,

  /// Setup never completed and a service dated in the last month: an
  /// account in use, older than the setup. Gets the essentials (profession,
  /// currency, cycle) and never a kit.
  returning,

  /// Setup completed and two or more services: an account in use. Gets the
  /// release note and the home nudge.
  active,

  /// Setup completed but not yet in use — or the check itself failed.
  done;

  /// Whether the blocking setup has to run.
  bool get requiresSetup =>
      this == fresh || this == dormant || this == returning;

  /// Whether the non-blocking nudge on the home applies.
  bool get isActiveUser => this == active;
}
