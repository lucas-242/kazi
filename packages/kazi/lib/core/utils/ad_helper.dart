import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

abstract class AdHelper {
  /// Builds the service-list banner. The caller owns it: it must call `load()`
  /// once and `dispose()` when the widget holding it goes away.
  static BannerAd? getBannerAd(
    String adUnitId, {
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) {
    if (adUnitId.isEmpty) {
      Log.error('Can\'t load banner ad - AdUnitId is empty.');
      return null;
    }

    return _buildBannerAd(
      adUnitId: adUnitId,
      size: AdSize.largeBanner,
      onLoaded: onLoaded,
      onFailed: onFailed,
    );
  }

  static BannerAd _buildBannerAd({
    required String adUnitId,
    AdSize size = AdSize.banner,
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) {
    return BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          Log.error(error);
          ad.dispose();
          onFailed?.call();
        },
      ),
    );
  }
}
