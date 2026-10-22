import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/models/errors.dart';

/// An HTTP status the API answered with. Value names are the second half of
/// the error code; renaming one splits its history in every report.
enum ApiFailure implements Failure {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  server;

  @override
  String get message {
    final l10n = KaziLocalizations.current;
    return switch (this) {
      notFound => l10n.errorNotFound,
      forbidden => l10n.errorAccessDenied,
      unauthorized => l10n.errorTokenExpired,
      timeout => l10n.errorTimeout,
      badRequest || server => l10n.errorUnknowError,
    };
  }

  @override
  ErrorKind get kind => switch (this) {
        timeout || server => ErrorKind.external,
        _ => ErrorKind.businessRule,
      };
}

final class ApiError extends ModuleError<ApiFailure> {
  ApiError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'api';
}
