// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes the signed-in account and everything it owns. See auth/README.md.
///
/// Kept alive because deleting the account signs it out, and the router then
/// disposes the screen that started it while the cleanup is still running.

@ProviderFor(DeleteAccountController)
const deleteAccountControllerProvider = DeleteAccountControllerProvider._();

/// Deletes the signed-in account and everything it owns. See auth/README.md.
///
/// Kept alive because deleting the account signs it out, and the router then
/// disposes the screen that started it while the cleanup is still running.
final class DeleteAccountControllerProvider
    extends $NotifierProvider<DeleteAccountController, AccountActionState> {
  /// Deletes the signed-in account and everything it owns. See auth/README.md.
  ///
  /// Kept alive because deleting the account signs it out, and the router then
  /// disposes the screen that started it while the cleanup is still running.
  const DeleteAccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountControllerHash();

  @$internal
  @override
  DeleteAccountController create() => DeleteAccountController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountActionState>(value),
    );
  }
}

String _$deleteAccountControllerHash() =>
    r'eb80b3ef13afd16e8c4a1dc61b6ff10e1522bc95';

/// Deletes the signed-in account and everything it owns. See auth/README.md.
///
/// Kept alive because deleting the account signs it out, and the router then
/// disposes the screen that started it while the cleanup is still running.

abstract class _$DeleteAccountController extends $Notifier<AccountActionState> {
  AccountActionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AccountActionState, AccountActionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountActionState, AccountActionState>,
              AccountActionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
