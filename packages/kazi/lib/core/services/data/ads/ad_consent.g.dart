// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_consent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether ads may be requested, as UMP last answered. False until the
/// bootstrap has run [gather]: no ad is requested before consent is known.
/// See README.md.

@ProviderFor(AdConsent)
const adConsentProvider = AdConsentProvider._();

/// Whether ads may be requested, as UMP last answered. False until the
/// bootstrap has run [gather]: no ad is requested before consent is known.
/// See README.md.
final class AdConsentProvider extends $NotifierProvider<AdConsent, bool> {
  /// Whether ads may be requested, as UMP last answered. False until the
  /// bootstrap has run [gather]: no ad is requested before consent is known.
  /// See README.md.
  const AdConsentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adConsentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adConsentHash();

  @$internal
  @override
  AdConsent create() => AdConsent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adConsentHash() => r'180d28c1aed9b4112a2fcd4d649d1346aa9cd96d';

/// Whether ads may be requested, as UMP last answered. False until the
/// bootstrap has run [gather]: no ad is requested before consent is known.
/// See README.md.

abstract class _$AdConsent extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Whether Menu › Privacy must carry the entry back into the consent choices.
/// Only meaningful once [AdConsent.gather] has run.

@ProviderFor(adPrivacyOptionsRequired)
const adPrivacyOptionsRequiredProvider = AdPrivacyOptionsRequiredProvider._();

/// Whether Menu › Privacy must carry the entry back into the consent choices.
/// Only meaningful once [AdConsent.gather] has run.

final class AdPrivacyOptionsRequiredProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether Menu › Privacy must carry the entry back into the consent choices.
  /// Only meaningful once [AdConsent.gather] has run.
  const AdPrivacyOptionsRequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adPrivacyOptionsRequiredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adPrivacyOptionsRequiredHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return adPrivacyOptionsRequired(ref);
  }
}

String _$adPrivacyOptionsRequiredHash() =>
    r'7c135aea7462c8d2464eda364d49194004b18f5e';
