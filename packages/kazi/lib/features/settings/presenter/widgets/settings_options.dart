import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/auth/presenter/widgets/sign_out_dialog.dart';
import 'package:kazi/features/settings/presenter/widgets/currency_bottom_sheet.dart';
import 'package:kazi/features/settings/presenter/widgets/language_bottom_sheet.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_group.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_option_button.dart';
import 'package:kazi/features/settings/presenter/widgets/theme_bottom_sheet.dart';
import 'package:kazi/features/subscription/subscription.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The menu: what defines the earnings, what adjusts the app, what talks about
/// the app — in that order.
///
/// Clients are not here: they are a destination of the bottom bar, consulted
/// daily, not configured monthly.
class SettingsOptions extends ConsumerWidget {
  const SettingsOptions({super.key, required this.onRateApp});
  final VoidCallback onRateApp;

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final isPaymentsEnabled = ref.watch(isPaymentsEnabledProvider);

    return Column(
      children: [
        if (isPaymentsEnabled && !isPremium)
          SettingsOptionButton(
            onTap: () => showPaywall(context),
            text: KaziLocalizations.current.goPremium,
            textStyle: KaziTextStyles.sm.copyWith(
              color: context.colorsScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        SettingsGroup(
          title: KaziLocalizations.current.myWork,
          children: [
            SettingsOptionButton(
              text: KaziLocalizations.current.serviceCatalog,
              onTap: () => KaziNavigator.push(AppPage.servicesType),
            ),
          ],
        ),
        SettingsGroup(
          title: KaziLocalizations.current.preferences,
          children: [
            SettingsOptionButton(
              text: KaziLocalizations.current.defaultCurrency,
              onTap: () => _showSheet(context, const CurrencyBottomSheet()),
            ),
            SettingsOptionButton(
              text: KaziLocalizations.current.language,
              onTap: () => _showSheet(context, const LanguageBottomSheet()),
            ),
            SettingsOptionButton(
              text: KaziLocalizations.current.theme,
              onTap: () => _showSheet(context, const ThemeBottomSheet()),
            ),
          ],
        ),
        SettingsGroup(
          title: KaziLocalizations.current.about,
          children: [
            SettingsOptionButton(
              onTap: onRateApp,
              text: KaziLocalizations.current.rateApp,
            ),
            SettingsOptionButton(
              onTap: () => KaziNavigator.push(AppPage.onboarding),
              text: KaziLocalizations.current.reviewOnboarding,
            ),
            SettingsOptionButton(
              // Destructive, so it is isolated at the end and marked in red.
              onTap: () => showSignOutDialog(context, ref),
              text: KaziLocalizations.current.signOut,
              textStyle: KaziTextStyles.titleSm.copyWith(
                color: context.colorsScheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
