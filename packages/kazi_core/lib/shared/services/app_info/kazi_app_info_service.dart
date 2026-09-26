abstract interface class KaziAppInfoService {
  /// Returns the installed app version name (e.g. `1.2.0`).
  Future<String> getVersion();
}
