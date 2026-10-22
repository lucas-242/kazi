import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Value names are the second half of the error code; renaming one splits its
/// history in every report.
enum SettingsFailure implements Failure {
  load,
  save,
  migrateCurrency;

  @override
  String get message {
    final l10n = KaziLocalizations.current;
    return switch (this) {
      load => l10n.errorToGetUserSettings,
      save => l10n.errorToSaveUserSettings,
      migrateCurrency => l10n.errorToMigrateCurrency,
    };
  }

  @override
  ErrorKind get kind => ErrorKind.external;
}

final class SettingsError extends ModuleError<SettingsFailure> {
  SettingsError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'settings';
}
