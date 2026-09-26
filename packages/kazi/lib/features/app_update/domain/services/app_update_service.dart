import 'package:kazi/features/app_update/domain/models/app_update_info.dart';

/// Resolves whether the installed app needs an update, based on remotely
/// published version requirements.
abstract interface class AppUpdateService {
  /// Compares the installed version against the published requirements.
  ///
  /// Implementations must be fail-open: any error resolves to
  /// [AppUpdateStatus.upToDate] so the user is never locked out by a failure.
  Future<AppUpdateInfo> checkForUpdate();
}
