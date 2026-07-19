import 'package:package_info_plus/package_info_plus.dart';

import 'kazi_app_info_service.dart';

final class KaziAppInfoServiceImpl implements KaziAppInfoService {
  KaziAppInfoServiceImpl({PackageInfo? packageInfo}) : _packageInfo = packageInfo;

  PackageInfo? _packageInfo;

  @override
  Future<String> getVersion() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!.version;
  }
}
