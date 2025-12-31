// app_router_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/shared/constants/storage_keys.dart';
import 'package:kazi_core/kazi_core.dart';

final routerControllerProvider = AsyncNotifierProvider<RouterController, bool>(
  RouterController.new,
);

class RouterController extends AsyncNotifier<bool> {
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
