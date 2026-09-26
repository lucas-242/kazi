// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profession_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The profession answered in the setup, as stored: a kit key or the user's own
/// words. Resolve it with `PresetCatalog.displayName` at build time, so a
/// language change renames it. Null when never answered or unreadable.

@ProviderFor(userProfession)
const userProfessionProvider = UserProfessionProvider._();

/// The profession answered in the setup, as stored: a kit key or the user's own
/// words. Resolve it with `PresetCatalog.displayName` at build time, so a
/// language change renames it. Null when never answered or unreadable.

final class UserProfessionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The profession answered in the setup, as stored: a kit key or the user's own
  /// words. Resolve it with `PresetCatalog.displayName` at build time, so a
  /// language change renames it. Null when never answered or unreadable.
  const UserProfessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfessionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return userProfession(ref);
  }
}

String _$userProfessionHash() => r'9194581cb0936b171155f6c504a981571d02e4d2';
