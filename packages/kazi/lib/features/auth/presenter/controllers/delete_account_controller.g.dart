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
    extends $NotifierProvider<DeleteAccountController, DeleteAccountState> {
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
  Override overrideWithValue(DeleteAccountState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountState>(value),
    );
  }
}

String _$deleteAccountControllerHash() =>
    r'68392ce26d61351da2491587f8477544dd52a4d1';

/// Deletes the signed-in account and everything it owns. See auth/README.md.
///
/// Kept alive because deleting the account signs it out, and the router then
/// disposes the screen that started it while the cleanup is still running.

abstract class _$DeleteAccountController extends $Notifier<DeleteAccountState> {
  DeleteAccountState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DeleteAccountState, DeleteAccountState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeleteAccountState, DeleteAccountState>,
              DeleteAccountState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
