// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_migration_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Asks users who registered services before multi-currency support which
/// currency those amounts were in, then stamps the answer onto them.
///
/// Without it there is no way to tell a service worth 100 BRL from one worth
/// 100 USD, and every total the app shows is a sum of unlike quantities.

@ProviderFor(CurrencyMigrationController)
const currencyMigrationControllerProvider =
    CurrencyMigrationControllerProvider._();

/// Asks users who registered services before multi-currency support which
/// currency those amounts were in, then stamps the answer onto them.
///
/// Without it there is no way to tell a service worth 100 BRL from one worth
/// 100 USD, and every total the app shows is a sum of unlike quantities.
final class CurrencyMigrationControllerProvider
    extends
        $NotifierProvider<CurrencyMigrationController, CurrencyMigrationState> {
  /// Asks users who registered services before multi-currency support which
  /// currency those amounts were in, then stamps the answer onto them.
  ///
  /// Without it there is no way to tell a service worth 100 BRL from one worth
  /// 100 USD, and every total the app shows is a sum of unlike quantities.
  const CurrencyMigrationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyMigrationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyMigrationControllerHash();

  @$internal
  @override
  CurrencyMigrationController create() => CurrencyMigrationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrencyMigrationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrencyMigrationState>(value),
    );
  }
}

String _$currencyMigrationControllerHash() =>
    r'4a125b4d880b289760f34d719b2c4239a845fcfd';

/// Asks users who registered services before multi-currency support which
/// currency those amounts were in, then stamps the answer onto them.
///
/// Without it there is no way to tell a service worth 100 BRL from one worth
/// 100 USD, and every total the app shows is a sum of unlike quantities.

abstract class _$CurrencyMigrationController
    extends $Notifier<CurrencyMigrationState> {
  CurrencyMigrationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<CurrencyMigrationState, CurrencyMigrationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CurrencyMigrationState, CurrencyMigrationState>,
              CurrencyMigrationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
