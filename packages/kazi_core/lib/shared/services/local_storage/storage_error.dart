import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/models/errors.dart';

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum StorageFailure implements Failure {
  read,
  write,

  /// A value of a type local storage cannot hold — a bug in the caller.
  unsupportedType;

  @override
  String get message => KaziLocalizations.current.errorUnknowError;

  @override
  ErrorKind get kind => switch (this) {
        unsupportedType => ErrorKind.unexpected,
        _ => ErrorKind.external,
      };
}

final class StorageError extends ModuleError<StorageFailure> {
  StorageError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'storage';
}
