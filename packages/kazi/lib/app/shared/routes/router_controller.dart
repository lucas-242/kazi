// app_router_provider.dart
import 'package:kazi/app/shared/constants/storage_keys.dart';
import 'package:kazi_core/kazi_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_controller.g.dart';

@riverpod
class RouterController extends _$RouterController {
  @override
  FutureOr<bool> build() async {
    final storage = await ref.watch(localStorageProvider.future);
    final hasSeenOnboarding =
        await storage.read<bool>(StorageKeys.showOnboarding) ?? false;
    return hasSeenOnboarding;
  }

  Future<void> setOnboardingSeen() async {
    final storage = await ref.read(localStorageProvider.future);
    await storage.write(StorageKeys.showOnboarding, true);
    state = const AsyncData(true);
  }
}
