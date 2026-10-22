import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum ClientsFailure implements Failure {
  load,
  count,
  loadHistory,
  countServices,
  findByDocument,
  add,
  update,
  archive,
  restore,
  delete,
  verifyDocument,
  documentTaken,
  documentArchived,
  nameRequired,
  phoneRequired;

  @override
  String get message {
    final l10n = KaziLocalizations.current;
    return switch (this) {
      load || count || loadHistory || findByDocument => l10n.errorToGetClients,
      countServices => l10n.errorToCountServices,
      add => l10n.errorToAddClient,
      update => l10n.errorToUpdateClient,
      archive => l10n.errorToArchiveClient,
      restore => l10n.errorToRestoreClient,
      delete => l10n.errorToDeleteClient,
      verifyDocument => l10n.errorToVerifyDocument,
      documentTaken || documentArchived => l10n.alreadyExists(l10n.document),
      nameRequired => l10n.requiredProperty(l10n.name),
      phoneRequired => l10n.requiredProperty(l10n.phone),
    };
  }

  @override
  ErrorKind get kind => switch (this) {
    documentTaken ||
    documentArchived ||
    nameRequired ||
    phoneRequired => ErrorKind.businessRule,
    _ => ErrorKind.external,
  };
}

final class ClientsError extends ModuleError<ClientsFailure> {
  ClientsError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'clients';
}
