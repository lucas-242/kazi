import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kazi_core/kazi_core.dart';

abstract class Environment {
  /// Name of envinroment key set in the build/run
  static const String _environmentKey = 'APP_ENV';
  static bool _isLoaded = false;

  static Future<void> load() async {
    if (_isLoaded) return;
    final fileName = '.env.${_flavor.value}';
    await dotenv.load(fileName: fileName);
    _isLoaded = true;
  }

  static Flavor get _flavor =>
      Flavor.fromString(const String.fromEnvironment(_environmentKey))!;

  static Environment get instance {
    switch (_flavor) {
      case Flavor.staging:
        return StagingEnvironment();
      case Flavor.prod:
      case Flavor.prodTest:
        return ProdEnvironment();
    }
  }

  Flavor get flavor => _flavor;

  String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';

  /// Public RevenueCat SDK key for the current platform (safe to embed).
  String get revenueCatApiKey => _checkEnvironmentAdKey(
    dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '',
    dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '',
  );

  /// Interstitial ad unit shown after a service/type/client is created.
  String get adKeyServiceCreate => _checkEnvironmentAdKey(
    dotenv.env['SERVICE_CREATE_ANDROID'] ?? '',
    dotenv.env['SERVICE_CREATE_IOS'] ?? '',
  );

  String get adKeyServiceList => _checkEnvironmentAdKey(
    dotenv.env['SERVICE_LIST_ANDROID'] ?? '',
    dotenv.env['SERVICE_LIST_IOS'] ?? '',
  );

  static const String androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.myservices.kazi';

  static const String iosStoreUrl = 'https://apps.apple.com/app/kazi';
}

class StagingEnvironment extends Environment {}

class ProdEnvironment extends Environment {}

String _checkEnvironmentAdKey(String android, String ios) {
  if (Platform.isAndroid) {
    return android;
  } else if (Platform.isIOS) {
    return ios;
  }

  return '';
}
