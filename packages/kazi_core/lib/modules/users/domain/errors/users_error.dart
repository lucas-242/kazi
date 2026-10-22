import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/models/errors.dart';

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum UsersFailure implements Failure {
  create,
  createClient,
  load,
  update,
  delete,
  notFound;

  @override
  String get message => switch (this) {
    notFound => KaziLocalizations.current.errorToLoadDetails,
    _ => KaziLocalizations.current.errorUnknowError,
  };

  @override
  ErrorKind get kind => switch (this) {
    notFound => ErrorKind.businessRule,
    _ => ErrorKind.external,
  };
}

final class UsersError extends ModuleError<UsersFailure> {
  UsersError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'users';
}
