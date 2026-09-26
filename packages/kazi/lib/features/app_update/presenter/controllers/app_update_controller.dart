import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/app_update/domain/models/app_update_info.dart';
import 'package:kazi/features/app_update/domain/services/app_update_service.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'app_update_state.dart';

part 'app_update_controller.g.dart';

@Riverpod(keepAlive: true)
class AppUpdateController extends _$AppUpdateController
    with BaseNotifier<AppUpdateState> {
  static const int _minDaysBetweenPrompts = 1;

  AppUpdateService get _appUpdateService => ref.read(appUpdateServiceProvider);

  @override
  AppUpdateState build() => AppUpdateState(status: BaseStateStatus.loading);

  bool get isMandatory => state.isMandatory;
  bool get isOptional => state.isOptional;
  AppUpdateInfo get info => state.info;

  Future<void> check() async {
    try {
      final info = await _appUpdateService.checkForUpdate();
      state = state.copyWith(status: BaseStateStatus.success, info: info);
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Whether the optional-update dialog should be shown now: only for an
  /// optional update and at most once per day. Records the prompt date when it
  /// returns `true`, so the caller can show the dialog right away.
  Future<bool> shouldShowOptionalDialog() async {
    if (!state.isOptional) {
      return false;
    }

    final storage = await ref.read(localStorageProvider.future);
    final lastPromptIso = await storage.read<String>(
      StorageKeys.lastOptionalUpdatePromptDate,
    );

    if (lastPromptIso != null) {
      final lastPrompt = DateTime.tryParse(lastPromptIso);
      if (lastPrompt != null &&
          DateTime.now().difference(lastPrompt).inDays <
              _minDaysBetweenPrompts) {
        return false;
      }
    }

    await storage.write<String>(
      StorageKeys.lastOptionalUpdatePromptDate,
      DateTime.now().toIso8601String(),
    );
    return true;
  }
}
