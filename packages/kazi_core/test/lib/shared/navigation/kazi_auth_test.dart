import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

class _FakeAuthService implements KaziAuthService {
  _FakeAuthService(this.authenticated);

  final bool authenticated;

  @override
  Stream<bool> authStateChanges() => Stream<bool>.value(authenticated);
}

void main() {
  group('KaziAppStartup', () {
    Future<KaziStartupState> resolve({
      required bool authenticated,
      required bool onboardingCompleted,
    }) {
      final container = ProviderContainer(
        overrides: [
          kaziAuthServiceProvider.overrideWithValue(
            _FakeAuthService(authenticated),
          ),
          kaziOnboardingCompletedProvider.overrideWith(
            (ref) async => onboardingCompleted,
          ),
        ],
      );
      addTearDown(container.dispose);
      return container.read(kaziAppStartupProvider.future);
    }

    test('Should go to login when signed out, even without onboarding',
        () async {
      final state = await resolve(
        authenticated: false,
        onboardingCompleted: false,
      );

      expect(state, KaziStartupState.login);
    });

    test('Should go to onboarding when signed in and it was not seen',
        () async {
      final state = await resolve(
        authenticated: true,
        onboardingCompleted: false,
      );

      expect(state, KaziStartupState.onboarding);
    });

    test('Should go home when signed in and onboarding was seen', () async {
      final state = await resolve(
        authenticated: true,
        onboardingCompleted: true,
      );

      expect(state, KaziStartupState.home);
    });
  });
}
