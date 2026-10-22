import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum SubscriptionFailure implements Failure {
  /// The user backed out of the store sheet — a decision, not a failure.
  purchaseCancelled,
  purchase,
  restore,
  offeringUnavailable;

  @override
  String get message => KaziLocalizations.current.errorUnknowError;

  @override
  ErrorKind get kind => switch (this) {
    purchaseCancelled => ErrorKind.businessRule,
    _ => ErrorKind.external,
  };
}

final class SubscriptionError extends ModuleError<SubscriptionFailure> {
  SubscriptionError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'subscription';
}
