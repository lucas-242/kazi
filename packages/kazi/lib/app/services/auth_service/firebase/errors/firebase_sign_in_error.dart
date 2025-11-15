import 'package:kazi_core/kazi_core.dart';

/// {@template firebase_sign_in_error}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class FirebaseSignInError extends ExternalError {
  /// {@macro firebase_sign_in_error}
  FirebaseSignInError({String? message})
    : super(message ?? KaziLocalizations.current.errorUnknowError);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory FirebaseSignInError.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential:':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorThereIsAnotherAccount,
        );
      case 'invalid-credential':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorCredentialIsInvalid,
        );
      case 'invalid-verification-code':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorVerificationCodeIsInvalid,
        );
      case 'invalid-verification-id':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorVerificationIdIsInvalid,
        );
      case 'operation-not-allowed':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorMethodNotAllowed,
        );
      case 'invalid-email':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorEmailIsInvalid,
        );
      case 'user-disabled':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorUserHasBeenDisabled,
        );
      case 'user-not-found':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorEmailWasNotFound,
        );
      case 'wrong-password':
        return FirebaseSignInError(
          message: KaziLocalizations.current.errorIncorrectEmailOrPassword,
        );
      default:
        return FirebaseSignInError();
    }
  }
}
