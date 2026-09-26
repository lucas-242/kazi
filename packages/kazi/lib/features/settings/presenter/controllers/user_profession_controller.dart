import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'user_profession_controller.g.dart';

/// The profession answered in the setup, as stored: a kit key or the user's own
/// words. Resolve it with `PresetCatalog.displayName` at build time, so a
/// language change renames it. Null when never answered or unreadable.
@riverpod
Future<String?> userProfession(Ref ref) async {
  final userId = ref.watch(authServiceProvider).user?.uid;
  if (userId == null) return null;

  try {
    final settings = await ref
        .watch(userSettingsRepositoryProvider)
        .get(userId);
    return settings.profession;
  } catch (exception) {
    Log.error(exception);
    return null;
  }
}
