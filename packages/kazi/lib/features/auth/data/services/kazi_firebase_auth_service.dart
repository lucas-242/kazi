import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi_core/kazi_core.dart';

/// Adapts the app's Firebase-backed [AuthService] to the shared
/// [KaziAuthService] contract consumed by the kazi_core router.
class KaziFirebaseAuthService implements KaziAuthService {
  const KaziFirebaseAuthService(this._authService);

  final AuthService _authService;

  @override
  Stream<bool> authStateChanges() => _authService.userChanges().map((user) {
    _authService.user = user;
    return user != null;
  });
}
