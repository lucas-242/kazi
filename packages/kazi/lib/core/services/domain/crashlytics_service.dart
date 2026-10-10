abstract class CrashlyticsService {
  /// Enables collection and installs the two global error handlers. Must run
  /// before anything that could fail; see core/README.md.
  Future<void> init();

  /// Reports a handled error as non-fatal, tagged with its `error_kind`.
  ///
  /// Reports each [exception] once: a failure logged where it was caught and
  /// again where it was shown to the user is one incident, not two. [reason]
  /// says where it surfaced.
  void log(Object exception, StackTrace stackTrace, {String? reason});

  /// Attributes every subsequent report to [userId], or clears the attribution
  /// when it is null.
  Future<void> setUser(String? userId);

  /// Attaches [value] to every subsequent report as a searchable key.
  Future<void> setCustomKey(String key, Object value);
}
