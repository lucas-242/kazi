import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'ad_consent.g.dart';

/// Whether ads may be requested, as UMP last answered. False until the
/// bootstrap has run [gather]: no ad is requested before consent is known.
/// See README.md.
@Riverpod(keepAlive: true)
class AdConsent extends _$AdConsent {
  @override
  bool build() => false;

  /// Presents the consent form if one is owed, then records the outcome.
  /// Never throws: a failed update still leaves the status persisted by an
  /// earlier launch, which is what `canRequestAds` reads.
  Future<void> gather() async {
    await _report(() => ref.read(adConsentServiceProvider).gather());
    await _refresh();
  }

  Future<void> showPrivacyOptions() async {
    await _report(
      () => ref.read(adConsentServiceProvider).showPrivacyOptions(),
    );
    await _refresh();
  }

  Future<void> _refresh() => _report(() async {
    state = await ref.read(adConsentServiceProvider).canRequestAds();
  });

  Future<void> _report(Future<void> Function() step) async {
    try {
      await step();
    } catch (exception, stackTrace) {
      Log.error('Ad consent failed: $exception');
      ref.read(crashlyticsServiceProvider).log(exception, stackTrace);
    }
  }
}

/// Whether Menu › Privacy must carry the entry back into the consent choices.
/// Only meaningful once [AdConsent.gather] has run.
@riverpod
Future<bool> adPrivacyOptionsRequired(Ref ref) async {
  ref.watch(adConsentProvider);
  try {
    return await ref.read(adConsentServiceProvider).isPrivacyOptionsRequired();
  } catch (exception) {
    Log.error(exception);
    return false;
  }
}
