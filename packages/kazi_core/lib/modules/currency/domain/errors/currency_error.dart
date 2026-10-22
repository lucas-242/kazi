import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/models/errors.dart';

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum CurrencyFailure implements Failure {
  /// The rates API answered with something other than 200.
  httpStatus,

  /// The rates API answered without a rates map.
  missingRates,
  fetch;

  @override
  String get message => KaziLocalizations.current.ratesUnavailable;

  @override
  ErrorKind get kind => ErrorKind.external;
}

final class CurrencyError extends ModuleError<CurrencyFailure> {
  CurrencyError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'currency';
}
