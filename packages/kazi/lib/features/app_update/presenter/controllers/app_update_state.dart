import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/app_update/domain/models/app_update_info.dart';

class AppUpdateState extends BaseState {
  AppUpdateState({
    required super.status,
    super.callbackMessage,
    this.info = const AppUpdateInfo.upToDate(),
  });

  final AppUpdateInfo info;

  bool get isMandatory => info.isMandatory;
  bool get isOptional => info.isOptional;

  @override
  AppUpdateState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    AppUpdateInfo? info,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      info: info ?? this.info,
    );
  }
}
