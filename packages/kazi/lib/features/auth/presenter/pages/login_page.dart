import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
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
  void _login() {
    ref
        .read(authServiceProvider)
        .signInWithGoogle()
        .then((isSignedIn) {
          if (isSignedIn && mounted) KaziNavigator.navigate(AppPage.onboarding);
        })
        .catchError((error) {
          if (mounted) KaziSnackbar.show(context, error.message);
        });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KaziSvg(
                      KaziSvgAssets.google,
                      height: 18,
                      color: KaziColors.white,
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
