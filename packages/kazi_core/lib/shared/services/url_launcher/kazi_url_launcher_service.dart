abstract interface class KaziUrlLauncherService {
  /// Opens [url] in an external application. Returns `true` on success.
  Future<bool> launch(String url);
}
