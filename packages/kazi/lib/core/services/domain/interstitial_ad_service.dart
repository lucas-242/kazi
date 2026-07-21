abstract class InterstitialAdService {
  /// Pre-loads the next interstitial so it can be shown without delay.
  void preload();

  /// Shows the loaded interstitial if one is ready, then pre-loads the next.
  /// Returns `true` when an ad was actually shown. No-ops (returns `false` and
  /// triggers a load) when none is ready yet.
  Future<bool> showIfAvailable();
}
