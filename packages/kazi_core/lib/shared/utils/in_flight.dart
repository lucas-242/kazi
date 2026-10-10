/// Drops a call whose key is still running, so a second tap — a rage click —
/// cannot write twice.
///
/// Key by what is written — `('archive', clientId)` — not by the action, so two
/// different records can still be acted on at once.
final class InFlight {
  final _running = <Object>{};

  /// Runs [action], or answers null without running it while [key] is.
  ///
  /// The key is taken synchronously, before [action] reaches its first
  /// `await`: that gap is exactly where a second tap lands.
  Future<T?> run<T>(Object key, Future<T> Function() action) async {
    if (!_running.add(key)) return null;
    try {
      return await action();
    } finally {
      _running.remove(key);
    }
  }
}
