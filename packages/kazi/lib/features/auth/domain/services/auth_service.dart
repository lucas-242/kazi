import 'package:kazi/features/auth/domain/models/app_user.dart';

abstract class AuthService {
  AppUser? user;

  Future<bool> signInWithGoogle();

  Future<void> signOut();

  Stream<AppUser?> userChanges();

  /// Asks the signed-in user to sign in again with the same account.
  ///
  /// Returns false when they back out. Throws when they pick a different
  /// account, so a deletion can never be confirmed by someone else's login.
  Future<bool> reauthenticate();

  /// Deletes the signed-in account from the auth provider, which also signs it
  /// out. Requires a [reauthenticate] in the last few minutes.
  Future<void> deleteAccount();
}
