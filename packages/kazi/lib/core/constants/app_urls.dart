/// Public web addresses the app links out to.
///
/// An empty value is rendered as plain text instead of a link: a dead link on
/// the gate is worse than no link, and the App Store and Play both ask for
/// reachable ones.
abstract final class AppUrls {
  /// Linked from the legal line on the login screen, and the web copy of what
  /// `PrivacyPolicyPage` renders from the `privacyPolice*` ARB keys.
  static const String privacyPolicy =
      'https://lucasguimaraesdev.blogspot.com/2023/05/kazi-privacy-police.html';
}
