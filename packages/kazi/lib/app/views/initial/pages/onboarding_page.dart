import 'package:flutter/material.dart';
import 'package:kazi/app/shared/constants/app_onboarding.dart';
import 'package:kazi/app/shared/extensions/routes_extensions.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorsScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(KaziInsets.xxLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset(AppAssets.onboarding)),
                RichText(
                  text: TextSpan(
                    text: KaziLocalizations.current.onboardingTitle1,
                    style: KaziTextStyles.headlineLg,
                    children: [
                      TextSpan(
                        text: KaziLocalizations.current.onboardingTitle2,
                        style: KaziTextStyles.headlineLg.copyWith(
                          color: context.colorsScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                KaziSpacings.verticalXs,
                Text(
                  KaziLocalizations.current.onboardingSubtitle,
                  style: KaziTextStyles.headlineSm,
                ),
                KaziSpacings.verticalXxLg,
                Center(
                  child: CircularButton(
                    iconSize: 54,
                    onTap: () {
                      AppOnboarding.onCompleteOnboarding(context);
                      context.navigateTo(AppPage.home);
                    },
                    child: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
