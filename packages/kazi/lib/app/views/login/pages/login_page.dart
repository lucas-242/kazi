import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kazi/app/services/auth_service/auth_service.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi/injector_container.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _login() {
    serviceLocator<AuthService>()
        .signInWithGoogle()
        .then((isSignedIn) {
          if (isSignedIn && mounted) context.navigateTo(AppPage.onboarding);
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
                      SvgPicture.asset(
                        AppAssets.logo,
                        height: KaziInsets.xxxLg,
                      ),
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
              PillButton(
                onTap: _login,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.google,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        KaziColors.white,
                        BlendMode.srcIn,
                      ),
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
