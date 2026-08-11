/// Public web addresses the app links out to.
///
/// TODO(kazi): publish the two legal documents and fill these in. While a
/// value is empty the login screen renders its label as plain text instead of a
/// link — a dead link on the gate is worse than no link, and the App Store and
/// Play both ask for reachable ones.
abstract final class AppUrls {
  /// Linked from the legal line on the login screen.
  static const String termsOfUse = '';

  /// Linked from the legal line on the login screen.
  ///
  /// The policy text itself already exists, translated, in the `privacyPolice*`
  /// ARB keys; nothing in the app renders it yet.
  static const String privacyPolicy = '';
}
