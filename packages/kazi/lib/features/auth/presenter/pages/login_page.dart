import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/router_controller.dart';
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

  Future<void> _login() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    try {
      final isSignedIn = await ref.read(authServiceProvider).signInWithGoogle();

      if (!isSignedIn) {
        if (mounted) setState(() => _isSigningIn = false);
        return;
      }

      final hasSeenOnboarding = await ref.read(routerControllerProvider.future);
      if (!mounted) return;

      KaziNavigator.navigate(
        hasSeenOnboarding ? AppPage.home : AppPage.onboarding,
      );
    } on AppError catch (error) {
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      KaziSnackbar.show(context, error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
    }
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
