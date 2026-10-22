import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum AuthFailure implements Failure {
  signIn,
  reauthenticate,
  signOut,
  deleteAccount,
  deleteData;

  @override
  String get message {
    final l10n = KaziLocalizations.current;
    return switch (this) {
      deleteData => l10n.errorToDeleteAccount,
      _ => l10n.errorUnknowError,
    };
  }

  @override
  ErrorKind get kind => ErrorKind.external;
}

final class AuthError extends ModuleError<AuthFailure> {
  AuthError(super.failure, {super.message, super.cause, super.trace});

  /// Explains Firebase Auth's [firebaseCode] to the user when it has a message
  /// of its own; the failure's otherwise.
  AuthError.fromFirebase(
    super.failure,
    String firebaseCode, {
    super.cause,
    super.trace,
  }) : super(message: _messageFor(firebaseCode));

  @override
  String get module => 'auth';

  static String? _messageFor(String code) {
    final l10n = KaziLocalizations.current;
    return switch (code) {
      'account-exists-with-different-credential' =>
        l10n.errorThereIsAnotherAccount,
      'invalid-credential' => l10n.errorCredentialIsInvalid,
      'invalid-verification-code' => l10n.errorVerificationCodeIsInvalid,
      'invalid-verification-id' => l10n.errorVerificationIdIsInvalid,
      'operation-not-allowed' => l10n.errorMethodNotAllowed,
      'invalid-email' => l10n.errorEmailIsInvalid,
      'user-disabled' => l10n.errorUserHasBeenDisabled,
      'user-not-found' => l10n.errorEmailWasNotFound,
      'user-mismatch' => l10n.errorReauthenticationWrongAccount,
      'wrong-password' => l10n.errorIncorrectEmailOrPassword,
      _ => null,
    };
  }
}
