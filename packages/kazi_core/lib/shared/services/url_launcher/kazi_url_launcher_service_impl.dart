import 'package:kazi_core/shared/utils/log_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'kazi_url_launcher_service.dart';

final class KaziUrlLauncherServiceImpl implements KaziUrlLauncherService {
  @override
  Future<bool> launch(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e, stackTrace) {
      Log.error('$e', stackTrace, 'Error launching url: $url');
      return false;
    }
  }
}
