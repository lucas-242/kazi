import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/shared/constants/app_assets.dart';
import 'package:kazi/app/shared/constants/storage_keys.dart';
import 'package:kazi/app/shared/extensions/routes_extensions.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onCompleteOnboarding() async {
      await ref
          .read(localStorageProvider.future)
          .then((value) => value.write(StorageKeys.showOnboarding, true));

      if (!context.mounted) return;
      context.navigateTo(AppPage.home);
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
