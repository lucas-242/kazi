/// Abstract base class for defining app pages.
/// Each app should extend this and define their specific pages.
abstract interface class KaziPage {
  /// Get the page from a route string
  static KaziPage? fromRoute(String route) => null;

  /// Get the page from an index
  static KaziPage fromIndex(int index) => throw UnimplementedError();

  /// The route path for this page
  String get route;

  /// The index for this page (for navigation bar, etc.)
  int get pageIndex;
}
