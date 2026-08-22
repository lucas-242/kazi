abstract class CrashlyticsService {
  /// Enables collection and installs the two global error handlers. Must run
  /// before anything that could fail; see core/README.md.
  Future<void> init();

  /// Reports a handled error as non-fatal.
  void log(Object exception, StackTrace stackTrace);

  /// Attributes every subsequent report to [userId], or clears the attribution
  /// when it is null.
  Future<void> setUser(String? userId);

  /// Attaches [value] to every subsequent report as a searchable key.
  Future<void> setCustomKey(String key, Object value);
}
