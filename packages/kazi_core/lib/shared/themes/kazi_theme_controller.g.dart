// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's theme choice, persisted on the device.
///
/// Device-scoped rather than account-scoped on purpose: theme is a property of
/// the phone the person is holding, so it survives signing out — unlike the
/// currency, which belongs to the work and travels with the account.

@ProviderFor(KaziThemeController)
const kaziThemeControllerProvider = KaziThemeControllerProvider._();

/// The user's theme choice, persisted on the device.
///
/// Device-scoped rather than account-scoped on purpose: theme is a property of
/// the phone the person is holding, so it survives signing out — unlike the
/// currency, which belongs to the work and travels with the account.
final class KaziThemeControllerProvider
    extends $AsyncNotifierProvider<KaziThemeController, ThemeMode> {
  /// The user's theme choice, persisted on the device.
  ///
  /// Device-scoped rather than account-scoped on purpose: theme is a property of
  /// the phone the person is holding, so it survives signing out — unlike the
  /// currency, which belongs to the work and travels with the account.
  const KaziThemeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziThemeControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziThemeControllerHash();

  @$internal
  @override
  KaziThemeController create() => KaziThemeController();
}

String _$kaziThemeControllerHash() =>
    r'ef7a8e0eaf40fb4c39397f88b6c0f2612dc2f98f';

/// The user's theme choice, persisted on the device.
///
/// Device-scoped rather than account-scoped on purpose: theme is a property of
/// the phone the person is holding, so it survives signing out — unlike the
/// currency, which belongs to the work and travels with the account.

abstract class _$KaziThemeController extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
        AsyncValue<ThemeMode>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
