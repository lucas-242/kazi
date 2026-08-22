import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'whats_new_controller.g.dart';

/// Decides whether to announce the release, once.
///
/// Only to people already using the app: someone signing up today has no
/// "before" to compare against, and the guided setup already showed them
/// everything on the list.
@Riverpod(keepAlive: true)
class WhatsNewController extends _$WhatsNewController {
  @override
  void build() {}

  Future<bool> shouldShow() async {
    final segment = await ref.read(onboardingControllerProvider.future);
    if (!segment.isActiveUser) return false;

    try {
      final storage = await ref.read(localStorageProvider.future);
      final seen = await storage.read<String>(StorageKeys.whatsNewSeenVersion);
      final current = await ref.read(kaziAppInfoServiceProvider).getVersion();
      return seen != current;
    } catch (exception) {
      // Cannot tell whether it was shown, so do not show it. An announcement
      // that repeats every launch is worse than one that is missed.
      Log.error(exception);
      return false;
    }
  }

  Future<void> markSeen() async {
    try {
      final storage = await ref.read(localStorageProvider.future);
      final current = await ref.read(kaziAppInfoServiceProvider).getVersion();
      await storage.write(StorageKeys.whatsNewSeenVersion, current);
    } catch (exception) {
      Log.error(exception);
    }
  }
}
