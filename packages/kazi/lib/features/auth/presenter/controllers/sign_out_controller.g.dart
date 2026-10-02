// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_out_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Signs the user out and wipes what this device kept for them.
///
/// It does not reset the onboarding: whether the setup was completed lives on
/// `users/{uid}`, so signing back into the same account correctly skips it.
///
/// Kept alive because signing out makes the router leave the screen that
/// started it while the cleanup is still running.

@ProviderFor(SignOutController)
const signOutControllerProvider = SignOutControllerProvider._();

/// Signs the user out and wipes what this device kept for them.
///
/// It does not reset the onboarding: whether the setup was completed lives on
/// `users/{uid}`, so signing back into the same account correctly skips it.
///
/// Kept alive because signing out makes the router leave the screen that
/// started it while the cleanup is still running.
final class SignOutControllerProvider
    extends $NotifierProvider<SignOutController, AccountActionState> {
  /// Signs the user out and wipes what this device kept for them.
  ///
  /// It does not reset the onboarding: whether the setup was completed lives on
  /// `users/{uid}`, so signing back into the same account correctly skips it.
  ///
  /// Kept alive because signing out makes the router leave the screen that
  /// started it while the cleanup is still running.
  const SignOutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutControllerHash();

  @$internal
  @override
  SignOutController create() => SignOutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountActionState>(value),
    );
  }
}

String _$signOutControllerHash() => r'bb3c6804b4fcd837c61b939f342ed31d28f64b44';

/// Signs the user out and wipes what this device kept for them.
///
/// It does not reset the onboarding: whether the setup was completed lives on
/// `users/{uid}`, so signing back into the same account correctly skips it.
///
/// Kept alive because signing out makes the router leave the screen that
/// started it while the cleanup is still running.

abstract class _$SignOutController extends $Notifier<AccountActionState> {
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
