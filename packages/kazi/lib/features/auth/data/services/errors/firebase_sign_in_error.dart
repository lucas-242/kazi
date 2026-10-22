import 'package:kazi_core/kazi_core.dart';

/// {@template firebase_sign_in_error}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class FirebaseSignInError extends ExternalError {
  /// {@macro firebase_sign_in_error}
  FirebaseSignInError({String? message, super.cause, super.trace})
    : super(message ?? KaziLocalizations.current.errorUnknowError);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory FirebaseSignInError.fromCode(
    String code, {
    Object? cause,
    StackTrace? trace,
  }) => FirebaseSignInError(
    message: _messageFor(code),
    cause: cause,
    trace: trace,
  );

  static String? _messageFor(String code) => switch (code) {
    'account-exists-with-different-credential' =>
      KaziLocalizations.current.errorThereIsAnotherAccount,
    'invalid-credential' => KaziLocalizations.current.errorCredentialIsInvalid,
    'invalid-verification-code' =>
      KaziLocalizations.current.errorVerificationCodeIsInvalid,
    'invalid-verification-id' =>
      KaziLocalizations.current.errorVerificationIdIsInvalid,
    'operation-not-allowed' => KaziLocalizations.current.errorMethodNotAllowed,
    'invalid-email' => KaziLocalizations.current.errorEmailIsInvalid,
    'user-disabled' => KaziLocalizations.current.errorUserHasBeenDisabled,
    'user-not-found' => KaziLocalizations.current.errorEmailWasNotFound,
    'user-mismatch' =>
      KaziLocalizations.current.errorReauthenticationWrongAccount,
    'wrong-password' => KaziLocalizations.current.errorIncorrectEmailOrPassword,
    _ => null,
  };
}
