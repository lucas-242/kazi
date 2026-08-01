import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/settings/presenter/widgets/currency_bottom_sheet.dart';
import 'package:kazi/features/settings/presenter/widgets/language_bottom_sheet.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_option_button.dart';
import 'package:kazi/features/subscription/subscription.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class SettingsOptions extends ConsumerWidget {
  const SettingsOptions({super.key, required this.onRateApp});
  final VoidCallback onRateApp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Column(
      children: [
        if (!isPremium) ...[
          SettingsOptionButton(
            onTap: () => showPaywall(context),
            text: KaziLocalizations.current.goPremium,
            textStyle: KaziTextStyles.sm.copyWith(
              color: context.colorsScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
            child: Divider(),
          ),
        ],
        SettingsOptionButton(
          text: KaziLocalizations.current.defaultCurrency,
          onTap: () => showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => const CurrencyBottomSheet(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        SettingsOptionButton(
          onTap: () => KaziNavigator.push(AppPage.servicesType),
          text: KaziLocalizations.current.serviceTypes,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        SettingsOptionButton(
          onTap: () => KaziNavigator.push(AppPage.clients),
          text: KaziLocalizations.current.clients,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        SettingsOptionButton(
          text: KaziLocalizations.current.language,
          onTap: () => showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => const LanguageBottomSheet(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: KaziInsets.lg),
          child: Divider(),
        ),
        SettingsOptionButton(
          onTap: onRateApp,
          text: KaziLocalizations.current.rateApp,
        ),
      ],
    );
  }
}
