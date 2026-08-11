import 'package:kazi_core/shared/utils/log_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_auth.g.dart';

/// App-agnostic authentication contract consumed by the shared router.
///
/// Each app provides an implementation (e.g. wrapping Firebase Auth) and
/// injects it by overriding [kaziAuthServiceProvider].
abstract interface class KaziAuthService {
  /// Emits `true` while a user is authenticated, `false` otherwise.
  Stream<bool> authStateChanges();
}

/// Overridable per app. Throws until an app injects its implementation.
@riverpod
KaziAuthService kaziAuthService(Ref ref) => throw UnimplementedError(
      'kaziAuthServiceProvider must be overridden per app',
    );

/// Overridable per app. Resolves whether the onboarding flow was completed.
@riverpod
Future<bool> kaziOnboardingCompleted(Ref ref) => throw UnimplementedError(
      'kaziOnboardingCompletedProvider must be overridden per app',
    );

/// Minimum time the splash stays visible so its animation can play, even when
/// startup data resolves faster. Overridable per app; defaults to no delay.
///
/// It is a *floor*, not a delay added on top: [KaziAppStartup] starts counting
/// it in parallel with the work it does, so a cold start costs the longer of
/// the two, never their sum.
@riverpod
Duration kaziMinimumSplashDuration(Ref ref) => Duration.zero;

/// App-specific asynchronous initialisation that has to be in place before the
/// first screen can be chosen: ad SDKs, remote config, an update check.
///
/// It belongs **here**, on the splash, and not in `main()` before `runApp`. Work
/// done before the first frame is spent on the platform splash — a screen the
/// app does not control and cannot animate — and it is spent *in addition to*
/// [kaziMinimumSplashDuration]. Awaited here, the same work runs while the
/// branded splash is on screen and inside the same window, so the person waits
/// once instead of twice.
///
/// Overridable per app; by default there is nothing to do.
@riverpod
Future<void> kaziAppBootstrap(Ref ref) async {}

/// High-level startup destination driving the initial redirect.
enum KaziStartupState { loading, onboarding, login, home }

@riverpod
class KaziIsAuthenticated extends _$KaziIsAuthenticated {
  @override
  Stream<bool> build() => ref.watch(kaziAuthServiceProvider).authStateChanges();
}

@riverpod
class KaziAppStartup extends _$KaziAppStartup {
  bool _splashShown = false;

  @override
  Future<KaziStartupState> build() async {
    // Only gate on the first startup: later rebuilds (e.g. finishing onboarding)
    // must not bring the splash back. Starts counting immediately; awaited last
    // so the splash stays visible for at least this long regardless of how fast
    // the data below resolves.
    final minimumSplash = _splashShown
        ? Future<void>.value()
        : Future<void>.delayed(ref.watch(kaziMinimumSplashDurationProvider));

    final state = await _resolveState();

    await minimumSplash;
    _splashShown = true;
    return state;
  }

  Future<KaziStartupState> _resolveState() async {
    // Guarded, unlike everything else here. This one await runs third-party
    // SDKs with their own failure modes, and a throw would leave `build` in an
    // error state — which the router reads as "startup never finished" and
    // answers by pinning the person to the splash for good. The bootstrap is
    // allowed to delay the app; it is not allowed to brick it.
    try {
      await ref.watch(kaziAppBootstrapProvider.future);
    } catch (exception, stackTrace) {
      Log.error('App bootstrap failed: $exception\n$stackTrace');
    }

    final authenticated =
        await ref.watch(kaziAuthServiceProvider).authStateChanges().first;

    if (!authenticated) {
      return KaziStartupState.login;
    }

    final onboardingCompleted = await ref.watch(
      kaziOnboardingCompletedProvider.future,
    );

    if (!onboardingCompleted) {
      return KaziStartupState.onboarding;
    }

    return KaziStartupState.home;
  }
}
