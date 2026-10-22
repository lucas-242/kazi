import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum CatalogFailure implements Failure {
  load,
  add,
  update,
  delete,
  archive,
  restore,
  nameRequired,
  duplicateName,
  inUse;

  @override
  String get message {
    final l10n = KaziLocalizations.current;
    return switch (this) {
      load => l10n.errorToGetCatalogItems,
      add => l10n.errorToAddCatalogItem,
      update => l10n.errorToUpdateCatalogItem,
      delete => l10n.errorToDeleteCatalogItem,
      archive => l10n.errorToArchiveCatalogItem,
      restore => l10n.errorToRestoreCatalogItem,
      nameRequired => l10n.requiredProperty(l10n.catalogItem),
      duplicateName => l10n.catalogItemDuplicateName,
      inUse => l10n.errorCantDeleteCatalogItem,
    };
  }

  @override
  ErrorKind get kind => switch (this) {
    nameRequired || duplicateName || inUse => ErrorKind.businessRule,
    _ => ErrorKind.external,
  };
}

final class CatalogError extends ModuleError<CatalogFailure> {
  CatalogError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'catalog';
}
