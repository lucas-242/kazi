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

/// High-level startup destination driving the initial redirect.
enum KaziStartupState { loading, onboarding, login, home }

@riverpod
class KaziIsAuthenticated extends _$KaziIsAuthenticated {
  @override
  Stream<bool> build() => ref.watch(kaziAuthServiceProvider).authStateChanges();
}

@riverpod
class KaziAppStartup extends _$KaziAppStartup {
  @override
  Future<KaziStartupState> build() async {
    final onboardingCompleted = await ref.watch(
      kaziOnboardingCompletedProvider.future,
    );

    if (!onboardingCompleted) {
      return KaziStartupState.onboarding;
    }

    final authenticated = await ref
        .watch(kaziAuthServiceProvider)
        .authStateChanges()
        .first;

    if (!authenticated) {
      return KaziStartupState.login;
    }

    return KaziStartupState.home;
  }
}
