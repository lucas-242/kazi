import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/router_controller.dart';
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
    return Scaffold(
      backgroundColor: context.colorsScheme.primary,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 140,
          bottom: 100,
          left: KaziInsets.xxLg,
          right: KaziInsets.xxLg,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KaziSvg(KaziSvgAssets.logo, height: KaziInsets.xxxLg),
                      Text(
                        'Kazi',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: context.colorsScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 36,
                            ),
                      ),
                    ],
                  ),
                  KaziSpacings.verticalXs,
                  Text(
                    KaziLocalizations.current.appSubtitle,
                    textAlign: TextAlign.center,
                    style: KaziTextStyles.headlineMd,
                  ),
                ],
              ),
              KaziSpacings.verticalXxxLg,
              KaziSpacings.verticalXLg,
              KaziPillButton(
                onTap: _login,
                backgroundColor: context.colorsScheme.inverseSurface,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KaziSvg(
                      KaziSvgAssets.google,
                      height: 18,
                      color: context.colorsScheme.onInverseSurface,
                    ),
                    KaziSpacings.horizontalXs,
                    Text(KaziLocalizations.current.googleSignIn),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
