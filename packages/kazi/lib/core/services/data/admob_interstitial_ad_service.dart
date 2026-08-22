import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/core/services/domain/interstitial_ad_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

final class AdMobInterstitialAdService implements InterstitialAdService {
  AdMobInterstitialAdService(this._adUnitId);

  final String _adUnitId;
  InterstitialAd? _ad;
  bool _isLoading = false;

  @override
  void preload() {
    if (_adUnitId.isEmpty || _ad != null || _isLoading) {
      return;
    }
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          Log.error('Failed to load interstitial ad: $error');
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  @override
  Future<bool> showIfAvailable() async {
    final ad = _ad;
    if (ad == null) {
      // Nothing ready this time; make sure the next one is loading.
      preload();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error('Failed to show interstitial ad: $error');
        ad.dispose();
        _ad = null;
        preload();
      },
    );
    // Detach before showing so a concurrent call can't show the same ad twice.
    _ad = null;
    await ad.show();
    return true;
  }
}
