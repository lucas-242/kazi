import 'dart:io';

import 'package:kazi/app/shared/constants/ad_keys.dart';
import 'package:kazi_core/kazi_core.dart';

abstract class Environment {
  /// Name of envinroment key set in the build/run
  static const String _environmentKey = 'APP_ENV';

  static EnvironmentValue get environmentValue => EnvironmentValue.fromString(
    const String.fromEnvironment(_environmentKey),
  )!;

  static Environment get instance => environmentValue == EnvironmentValue.dev
      ? DevEnvironment()
      : ProdEnvironment();

  String get adKeyServiceCreate;
  String get adKeyServiceList;
}

class DevEnvironment extends Environment {
  @override
  String get adKeyServiceCreate => _checkEnvironmentAdKey(
    AdKeys.serviceCreateAndroidDebug,
    AdKeys.serviceCreateIOSDebug,
  );

  @override
  String get adKeyServiceList => _checkEnvironmentAdKey(
    AdKeys.serviceListAndroidDebug,
    AdKeys.serviceListIOSDebug,
  );
}

class ProdEnvironment extends Environment {
  @override
  String get adKeyServiceCreate => _checkEnvironmentAdKey(
    AdKeys.serviceCreateAndroidProd,
    AdKeys.serviceCreateIOSProd,
  );

  @override
  String get adKeyServiceList => _checkEnvironmentAdKey(
    AdKeys.serviceListAndroidProd,
    AdKeys.serviceListIOSProd,
  );
}

String _checkEnvironmentAdKey(String android, String ios) {
  if (Platform.isAndroid) {
    return android;
  } else if (Platform.isIOS) {
    return ios;
  }

  return '';
}
