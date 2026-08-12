/// Which onboarding treatment an account gets.
///
/// Sending everyone through the same setup would be the worst possible move:
/// asking someone with forty registered services to "build your catalog" tells
/// them the app has no idea who they are. So the base splits, and each part is
/// treated differently.
enum OnboardingSegment {
  /// Brand new: nothing registered. Gets the full five-screen setup.
  fresh,

  /// Signed up but never got going — at most one service. The people who
  /// arrived and left, and the ones this whole delivery is aimed at. Same
  /// setup as [fresh]; the only difference is that whatever little they do
  /// have must survive it.
  stalled,

  /// Actually using the app: two or more services registered. Never blocked,
  /// never shown a full screen. They open the app to record work, and anything
  /// standing between them and that is how an active user is lost.
  active,

  /// Nothing to do — already resolved, or the feature is switched off.
  done;

  /// Whether the blocking five-screen setup has to run.
  bool get requiresSetup => this == fresh || this == stalled;

  /// Whether the non-blocking nudges on the home apply.
  bool get isActiveUser => this == active;
}
