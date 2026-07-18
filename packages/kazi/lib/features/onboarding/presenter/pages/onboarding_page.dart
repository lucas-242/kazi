import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onCompleteOnboarding() async {
      await ref.read(routerControllerProvider.notifier).setOnboardingSeen();

      if (!context.mounted) return;
      KaziNavigator.navigate(AppPage.home);
    }

    return Scaffold(
      backgroundColor: context.colorsScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(KaziInsets.xxLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset(KaziImageAssets.onboarding)),
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
                  child: KaziCircularButton(
                    iconSize: 54,
                    onTap: onCompleteOnboarding,
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
