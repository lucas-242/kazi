import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/auth/presenter/widgets/login_legal_text.dart';
import 'package:kazi/features/auth/presenter/widgets/sign_in_provider_button.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSigningIn = false;

  /// The only provider today, sent as a parameter anyway so the funnel does not
  /// have to be rebuilt the day a second one is added.
  static const String _provider = 'google';

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  Future<void> _login() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    unawaited(
      _analytics.log(
        AnalyticsEvent.loginStarted,
        parameters: const {'provider': _provider},
      ),
    );

    try {
      final isSignedIn = await ref.read(authServiceProvider).signInWithGoogle();

      if (!isSignedIn) {
        // Not an error: the Google sheet was dismissed. Told apart from a
        // failure because the two need completely different answers — one is a
        // hesitation, the other is a bug.
        unawaited(
          _analytics.log(
            AnalyticsEvent.loginFailed,
            parameters: const {'provider': _provider, 'reason': 'dismissed'},
          ),
        );
        if (mounted) setState(() => _isSigningIn = false);
        return;
      }

      unawaited(
        _analytics.log(
          AnalyticsEvent.loginCompleted,
          parameters: {
            'provider': _provider,
            'is_new_user': _isNewUser(),
          },
        ),
      );

      // No navigation here on purpose. The router's redirect owns the
      // onboarding-versus-home decision and re-runs as soon as the auth stream
      // emits; deciding it a second time from this screen was a second source
      // of truth, and it could only ever disagree with the first.
    } on AppError catch (error) {
      _reportFailure(error);
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      KaziSnackbar.show(context, error.message);
    } catch (error) {
      _reportFailure(error);
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
    }
  }

  /// Whether the account was created by this very sign-in, from Firebase Auth's
  /// own creation timestamp. It splits the funnel into acquisition and return,
  /// which behave nothing alike from here on.
  bool _isNewUser() {
    final createdAt = ref.read(authServiceProvider).user?.createdAt;
    if (createdAt == null) return false;
    return ref
            .read(timeServiceProvider)
            .now
            .difference(createdAt)
            .inMinutes
            .abs() <
        2;
  }

  /// The error's class, never its message: a sign-in message can quote the
  /// address the person typed.
  void _reportFailure(Object error) {
    unawaited(
      _analytics.log(
        AnalyticsEvent.loginFailed,
        parameters: {
          'provider': _provider,
          'reason': error.runtimeType.toString(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KaziBlockingLoading(
      isLoading: _isSigningIn,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final hero = context.colors.hero;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.colors.overlayOn(hero.surface),
      child: Scaffold(
        backgroundColor: hero.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: KaziInsets.xLg,
                vertical: KaziInsets.xxLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: KaziSvg(
                      KaziSvgAssets.logo,
                      height: KaziSizings.loginLogoHeight,
                      color: hero.ink,
                    ),
                  ),
                  KaziSpacings.verticalMd,
                  Text(
                    KaziLocalizations.current.loginHeadline,
                    style: KaziTextStyles.headlineLarge.copyWith(
                      color: hero.ink,
                    ),
                  ),
                  KaziSpacings.verticalXs,
                  Text(
                    KaziLocalizations.current.loginSubtitle,
                    style: KaziTextStyles.bodyLarge.copyWith(color: hero.muted),
                  ),
                  KaziSpacings.verticalLg,
                  SignInProviderButton(
                    onTap: _login,
                    label: KaziLocalizations.current.continueWithGoogle,
                    icon: const KaziSvg(KaziSvgAssets.google),
                  ),
                  KaziSpacings.verticalMd,
                  LoginLegalText(color: hero.muted, linkColor: hero.ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
