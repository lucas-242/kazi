import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

abstract class CrashlyticsService {
  /// Enables collection and installs the two global error handlers. Must run
  /// before anything that could fail; see core/README.md.
  Future<void> init();

  /// Reports a handled error as non-fatal: its root cause, tagged with the
  /// `error_code` and `error_kind` of [exception].
  ///
  /// Reports each root cause once: a failure logged where it was caught and
  /// again where it was shown to the user is one incident, not two. [reason]
  /// says where it surfaced, and defaults to the code.
  void log(Object exception, StackTrace stackTrace, {String? reason});

  /// Attributes every subsequent report to [userId], or clears the attribution
  /// when it is null.
  Future<void> setUser(String? userId);

  /// Attaches [value] to every subsequent report as a searchable key.
  Future<void> setCustomKey(String key, Object value);
}

extension CrashlyticsFailure on CrashlyticsService {
  /// The end of every repository `catch`: prints [error], reports it with its
  /// code, and throws it. Reported here because several callers swallow
  /// repository errors on purpose. See crashlytics/README.md.
  Never fail(AppError error) {
    final trace = error.trace ?? StackTrace.current;
    Log.error(error, trace);
    log(error, trace);
    throw error;
  }
}
