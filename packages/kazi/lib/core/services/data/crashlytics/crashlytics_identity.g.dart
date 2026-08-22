// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crashlytics_identity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stamps every crash report with who hit it and which build they were on.
///
/// Kept apart from `AnalyticsIdentityController` despite the overlap: that one
/// describes cohorts and is gated by the user's consent, this one is diagnostic
/// and is not. Both use the Firebase uid, so a crash and a funnel drop-off can
/// be matched to the same person.

@ProviderFor(CrashlyticsIdentity)
const crashlyticsIdentityProvider = CrashlyticsIdentityProvider._();

/// Stamps every crash report with who hit it and which build they were on.
///
/// Kept apart from `AnalyticsIdentityController` despite the overlap: that one
/// describes cohorts and is gated by the user's consent, this one is diagnostic
/// and is not. Both use the Firebase uid, so a crash and a funnel drop-off can
/// be matched to the same person.
final class CrashlyticsIdentityProvider
    extends $AsyncNotifierProvider<CrashlyticsIdentity, void> {
  /// Stamps every crash report with who hit it and which build they were on.
  ///
  /// Kept apart from `AnalyticsIdentityController` despite the overlap: that one
  /// describes cohorts and is gated by the user's consent, this one is diagnostic
  /// and is not. Both use the Firebase uid, so a crash and a funnel drop-off can
  /// be matched to the same person.
  const CrashlyticsIdentityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashlyticsIdentityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashlyticsIdentityHash();

  @$internal
  @override
  CrashlyticsIdentity create() => CrashlyticsIdentity();
}

String _$crashlyticsIdentityHash() =>
    r'0c7d207c7aa7d9892339eb2b975b88412cd3fa27';

/// Stamps every crash report with who hit it and which build they were on.
///
/// Kept apart from `AnalyticsIdentityController` despite the overlap: that one
/// describes cohorts and is gated by the user's consent, this one is diagnostic
/// and is not. Both use the Firebase uid, so a crash and a funnel drop-off can
/// be matched to the same person.

abstract class _$CrashlyticsIdentity extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
