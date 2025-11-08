import 'package:flutter/material.dart';
import 'package:kazi/app/shared/constants/app_onboarding.dart';
import 'package:kazi/app/shared/extensions/routes_extensions.dart';
import 'package:kazi/app/shared/l10n/generated/l10n.dart';
import 'package:kazi/app/shared/themes/themes.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
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
                Center(
                  child: Image.asset(AppAssets.onboarding),
                ),
                RichText(
                  text: TextSpan(
                    text: AppLocalizations.current.onboardingTitle1,
                    style: context.headlineLarge,
                    children: [
                      TextSpan(
                        text: AppLocalizations.current.onboardingTitle2,
                        style: context.headlineLarge!
                            .copyWith(color: context.colorsScheme.primary),
                      ),
                    ],
                  ),
                ),
                KaziSpacings.verticalXs,
                Text(
                  AppLocalizations.current.onboardingSubtitle,
                  style: context.headlineSmall,
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
