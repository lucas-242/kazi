/// Public web addresses the app links out to.
///
/// TODO(kazi): publish the terms of use and fill it in. While a value is empty
/// the login screen renders its label as plain text instead of a link — a dead
/// link on the gate is worse than no link, and the App Store and Play both ask
/// for reachable ones.
abstract final class AppUrls {
  /// Linked from the legal line on the login screen.
  static const String termsOfUse = '';

  /// Linked from the legal line on the login screen, and the web copy of what
  /// `PrivacyPolicyPage` renders from the `privacyPolice*` ARB keys.
  ///
  /// Both have to say the same thing: the page in the app is the one people
  /// reach from the privacy switches, and this one is what the stores require
  /// to be reachable without installing anything.
  static const String privacyPolicy =
      'https://lucasguimaraesdev.blogspot.com/2023/05/kazi-privacy-police.html';
}
