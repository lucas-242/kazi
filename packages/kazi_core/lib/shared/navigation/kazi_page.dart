/// Abstract base class for defining app pages.
/// Each app should extend this (usually with an enum) and define their
/// specific pages.
///
/// Route resolution (from a path or an index) is app-specific and cannot be
/// expressed here because static members are not polymorphic. Provide those
/// resolvers on the implementing enum and hand them to
/// [KaziNavigator.init] via `pageResolver`.
abstract interface class KaziPage {
  /// The route path for this page
  String get route;

  /// The index for this page (for navigation bar, etc.)
  int get pageIndex;
}
