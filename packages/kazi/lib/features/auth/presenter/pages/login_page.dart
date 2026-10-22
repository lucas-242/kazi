import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/features/auth/domain/models/sign_in_provider.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/auth/presenter/widgets/login_legal_text.dart';
import 'package:kazi/features/auth/presenter/widgets/sign_in_provider_button.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSigningIn = false;

  /// App Review requires it alongside Google on iOS (guideline 4.8). Android
  /// would need Apple's web flow, which is not configured.
  bool get _offersApple => defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _login(SignInProvider provider) async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    // Resolved before the sign-in: the auth stream drives the router's
    // redirect, which can unmount this page before `signIn` returns, and `ref`
    // throws once it has.
    final analytics = ref.read(analyticsServiceProvider);
    final authService = ref.read(authServiceProvider);
    final time = ref.read(timeServiceProvider);

    void logFailure(String reason) => unawaited(
      analytics.log(
        AnalyticsEvent.loginFailed,
        parameters: {'provider': provider.name, 'reason': reason},
      ),
    );

    unawaited(
      analytics.log(
        AnalyticsEvent.loginStarted,
        parameters: {'provider': provider.name},
      ),
    );

    try {
      final isSignedIn = await authService.signIn(provider);

      if (!isSignedIn) {
        // Not an error: the provider's sheet was dismissed. Told apart from a
        // failure because the two need completely different answers — one is a
        // hesitation, the other is a bug.
        logFailure('dismissed');
        if (mounted) setState(() => _isSigningIn = false);
        return;
      }

      unawaited(
        analytics.log(
          AnalyticsEvent.loginCompleted,
          parameters: {
            'provider': provider.name,
            'is_new_user': _isNewUser(authService, time),
          },
        ),
      );

      // No navigation here on purpose. The router's redirect owns the
      // onboarding-versus-home decision and re-runs as soon as the auth stream
      // emits; deciding it a second time from this screen was a second source
      // of truth, and it could only ever disagree with the first.
    } catch (error, trace) {
      logFailure(failureReason(error));
      if (!mounted) return;
      reportShownError(ref.read, error, trace, origin: 'LoginPage');
      setState(() => _isSigningIn = false);
      KaziSnackbar.show(
        context,
        error is AppError
            ? error.message
            : KaziLocalizations.current.errorUnknowError,
      );
    }
  }

  /// Whether the account was created by this very sign-in, from Firebase Auth's
  /// own creation timestamp. It splits the funnel into acquisition and return,
  /// which behave nothing alike from here on.
  static bool _isNewUser(AuthService authService, TimeService time) {
    final createdAt = authService.user?.createdAt;
    if (createdAt == null) return false;
    return time.now.difference(createdAt).inMinutes.abs() < 2;
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
                  if (_offersApple) ...[
                    // Apple's guidelines allow only a black or white button.
                    SignInProviderButton(
                      onTap: () => _login(SignInProvider.apple),
                      label: KaziLocalizations.current.continueWithApple,
                      icon: Icon(Icons.apple, color: context.colors.onInverse),
                      backgroundColor: context.colors.inverse,
                      foregroundColor: context.colors.onInverse,
                    ),
                    KaziSpacings.verticalSm,
                  ],
                  SignInProviderButton(
                    onTap: () => _login(SignInProvider.google),
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
