import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'crashlytics_identity.g.dart';

/// Stamps every crash report with who hit it and which build they were on.
///
/// Kept apart from `AnalyticsIdentityController` despite the overlap: that one
/// describes cohorts and is gated by the user's consent, this one is diagnostic
/// and is not. Both use the Firebase uid, so a crash and a funnel drop-off can
/// be matched to the same person.
@Riverpod(keepAlive: true)
class CrashlyticsIdentity extends _$CrashlyticsIdentity {
  @override
  Future<void> build() async {
    final crashlytics = ref.watch(crashlyticsServiceProvider);

    // `prod` and `prod_test` report into the same Firebase project, and
    // prod_test is the one running test ad units. Without this key an internal
    // build's crash is indistinguishable from a user's.
    await crashlytics.setCustomKey(
      'flavor',
      Environment.instance.flavor.value,
    );
    await crashlytics.setCustomKey(
      'is_premium',
      ref.watch(isPremiumProvider),
    );

    // Watched for the rebuild, not the boolean: this stream's `map` is what
    // assigns `authService.user`, so subscribing is what guarantees the uid
    // below is current.
    final authenticated = ref.watch(kaziIsAuthenticatedProvider).asData?.value;
    final user = ref.watch(authServiceProvider).user;

    await crashlytics.setUser(authenticated == true ? user?.uid : null);
  }
}
