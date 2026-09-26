/// The shapes of "this person is struggling" the app can recognise.
///
/// Detected in Dart because PostHog's own rage-click autocapture covers iOS and
/// Mac Catalyst only, and Kazi ships on Play.
enum FrictionKind {
  /// The same error, on the same screen, twice in a minute.
  repeatedError('repeated_error'),

  /// Several taps on one control that either did nothing or did not look like
  /// it did.
  rageTap('rage_tap'),

  /// A creation form held open far past the time it takes to fill, then left.
  formStall('form_stall'),

  /// The same form opened and abandoned twice with nothing created in between.
  loop('loop');

  const FrictionKind(this.name);

  final String name;
}
