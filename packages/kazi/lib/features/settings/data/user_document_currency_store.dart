import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Backs the shared default-currency contract with the user document, so the
/// choice survives sign-out (which clears local storage) and follows the user
/// to another device.
final class UserDocumentCurrencyStore implements KaziRemoteCurrencyStore {
  const UserDocumentCurrencyStore({
    required UserSettingsRepository repository,
    required AuthService authService,
  })  : _repository = repository,
        _authService = authService;

  final UserSettingsRepository _repository;
  final AuthService _authService;

  @override
  Future<SupportedCurrency?> read() async {
    final userId = _authService.user?.uid;
    if (userId == null) return null;

    final settings = await _repository.get(userId);
    return settings.defaultCurrency;
  }

  @override
  Future<void> write(SupportedCurrency currency) async {
    final userId = _authService.user?.uid;
    if (userId == null) return;

    await _repository.setDefaultCurrency(userId, currency);
  }
}
