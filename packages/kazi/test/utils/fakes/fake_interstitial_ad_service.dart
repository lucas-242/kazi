import 'package:kazi/core/services/domain/interstitial_ad_service.dart';

class FakeInterstitialAdService implements InterstitialAdService {
  FakeInterstitialAdService({this.hasAd = true});

  /// Whether [showIfAvailable] finds an ad ready.
  final bool hasAd;

  int preloadCount = 0;
  int showCount = 0;

  @override
  void preload() => preloadCount++;

  @override
  Future<bool> showIfAvailable() async {
    showCount++;
    return hasAd;
  }
}
