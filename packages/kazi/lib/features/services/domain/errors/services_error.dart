import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum ServicesFailure implements Failure {
  load,
  count,
  add,
  update,
  delete,
  markReceived,
  cancel,
  finish,
  catalogItemRequired,
  finishedCannotBeCancelled,
  cancelledCannotBeFinished,
  finishedBeforeStart,
  finishedInFuture;

  @override
  String get message {
    final l10n = KaziLocalizations.current;
    return switch (this) {
      load => l10n.errorToGetServices,
      count => l10n.errorToCountServices,
      add => l10n.errorToAddService,
      update => l10n.errorToUpdateService,
      delete => l10n.errorToDeleteService,
      markReceived => l10n.errorToMarkReceived,
      cancel => l10n.errorToCancelService,
      finish => l10n.errorToFinishService,
      catalogItemRequired => l10n.requiredProperty(l10n.catalogItem),
      finishedCannotBeCancelled => l10n.finishedServiceCannotBeCancelled,
      cancelledCannotBeFinished => l10n.cancelledServiceCannotBeFinished,
      finishedBeforeStart => l10n.finishedBeforeStart,
      finishedInFuture => l10n.finishedInFuture,
    };
  }

  @override
  ErrorKind get kind => switch (this) {
    catalogItemRequired ||
    finishedCannotBeCancelled ||
    cancelledCannotBeFinished ||
    finishedBeforeStart ||
    finishedInFuture => ErrorKind.businessRule,
    _ => ErrorKind.external,
  };
}

final class ServicesError extends ModuleError<ServicesFailure> {
  ServicesError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'services';
}
