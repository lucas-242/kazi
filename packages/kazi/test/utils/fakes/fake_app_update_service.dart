import 'package:kazi/features/app_update/domain/models/app_update_info.dart';
import 'package:kazi/features/app_update/domain/services/app_update_service.dart';

class FakeAppUpdateService implements AppUpdateService {
  FakeAppUpdateService({
    this.info = const AppUpdateInfo.upToDate(),
    this.error,
  });

  final AppUpdateInfo info;

  /// When set, [checkForUpdate] throws it instead of answering.
  final Object? error;

  @override
  Future<AppUpdateInfo> checkForUpdate() async {
    if (error != null) throw error!;
    return info;
  }
}
