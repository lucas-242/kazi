import 'package:kazi/app/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/models/errors.dart';

/// {@template firebase_sign_in_error}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class FirebaseSignInError extends ExternalError {
  /// {@macro firebase_sign_in_error}
  FirebaseSignInError({String? message})
    : super(message ?? AppLocalizations.current.unknowError);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory FirebaseSignInError.fromCode(String code, [String? trace]) {
    switch (code) {
      case 'account-exists-with-different-credential:':
        return FirebaseSignInError(
          message: AppLocalizations.current.thereIsAnotherAccount,
        );
      case 'invalid-credential':
        return FirebaseSignInError(
          message: AppLocalizations.current.credentialIsInvalid,
        );
      case 'invalid-verification-code':
        return FirebaseSignInError(
          message: AppLocalizations.current.verificationCodeIsInvalid,
        );
      case 'invalid-verification-id':
        return FirebaseSignInError(
          message: AppLocalizations.current.verificationIdIsInvalid,
        );
      case 'operation-not-allowed':
        return FirebaseSignInError(
          message: AppLocalizations.current.methodNotAllowed,
        );
      case 'invalid-email':
        return FirebaseSignInError(
          message: AppLocalizations.current.emailIsInvalid,
        );
      case 'user-disabled':
        return FirebaseSignInError(
          message: AppLocalizations.current.userHasBeenDisabled,
        );
      case 'user-not-found':
        return FirebaseSignInError(
          message: AppLocalizations.current.emailWasNotFound,
        );
      case 'wrong-password':
        return FirebaseSignInError(
          message: AppLocalizations.current.incorrectEmailOrPassword,
        );
      default:
        return FirebaseSignInError();
    }
  }
}
