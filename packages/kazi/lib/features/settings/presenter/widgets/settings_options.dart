import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/auth/presenter/widgets/sign_out_dialog.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/controllers/active_user_nudges_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi/features/settings/domain/models/privacy_settings.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/features/settings/presenter/controllers/privacy_controller.dart';
import 'package:kazi/features/settings/presenter/widgets/billing_cycle_l10n.dart';
import 'package:kazi/features/settings/presenter/widgets/currency_bottom_sheet.dart';
import 'package:kazi/features/settings/presenter/widgets/language_bottom_sheet.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_group.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_option_button.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_switch_button.dart';
import 'package:kazi/features/settings/presenter/widgets/theme_bottom_sheet.dart';
import 'package:kazi/features/subscription/subscription.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The menu: what defines the earnings, what adjusts the app, what talks about
/// the app — in that order. Clients are a bottom-bar destination, not a
/// setting: consulted daily, not configured monthly.
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

    // Each preference row reports the value in force, so the menu answers
    // "which currency am I in?" without opening anything.
    final currency = ref.watch(kaziDefaultCurrencyProvider);
    final cycle = ref.watch(billingCycleProvider);
    final locale = ref.watch(kaziEffectiveLocaleProvider);
    final themeMode =
        ref.watch(kaziThemeControllerProvider).asData?.value ?? ThemeMode.system;

    // Defaults while loading, not a spinner: these resolve from local storage
    // within a frame or two and must not reserve a hole.
    final privacy =
        ref.watch(privacyControllerProvider).asData?.value ??
        const PrivacySettings();

    return Column(
      children: [
        if (isPaymentsEnabled && !isPremium)
          SettingsOptionButton(
            onTap: () => showPaywall(context),
            text: KaziLocalizations.current.goPremium,
            icon: Icons.workspace_premium_outlined,
            isHighlighted: true,
          ),
        SettingsGroup(
          title: KaziLocalizations.current.myWork,
          children: [
            SettingsOptionButton(
              text: KaziLocalizations.current.serviceCatalog,
              icon: Icons.sell_outlined,
              onTap: () => KaziNavigator.push(AppPage.serviceCatalog),
            ),
          ],
        ),
        SettingsGroup(
          title: KaziLocalizations.current.preferences,
          children: [
            SettingsOptionButton(
              // A page, not a sheet: it carries a picker of its own.
              text: KaziLocalizations.current.billingCycle,
              icon: Icons.event_repeat_outlined,
              value: cycle.type.label,
              onTap: () => KaziNavigator.push(AppPage.billingCycle),
            ),
            SettingsOptionButton(
              text: KaziLocalizations.current.defaultCurrency,
              icon: Icons.payments_outlined,
              value: '${currency.isoCode} · ${currency.symbol}',
              onTap: () => _showSheet(context, const CurrencyBottomSheet()),
            ),
            SettingsOptionButton(
              text: KaziLocalizations.current.language,
              icon: Icons.language,
              value: _languageLabel(locale.languageCode),
              onTap: () => _showSheet(context, const LanguageBottomSheet()),
            ),
            SettingsOptionButton(
              text: KaziLocalizations.current.theme,
              icon: Icons.dark_mode_outlined,
              value: _themeLabel(themeMode),
              onTap: () => _showSheet(context, const ThemeBottomSheet()),
            ),
          ],
        ),
        // Its own group, not under "About": these are settings, not legal
        // small print, and a buried opt-out is one nobody can find.
        SettingsGroup(
          title: KaziLocalizations.current.privacy,
          children: [
            SettingsSwitchButton(
              value: privacy.isAnalyticsAllowed,
              onChanged: (enabled) => ref
                  .read(privacyControllerProvider.notifier)
                  .setAnalyticsEnabled(enabled),
              text: KaziLocalizations.current.privacyUsageData,
              description: KaziLocalizations.current.privacyUsageDataDescription,
              icon: Icons.insights_outlined,
            ),
            SettingsSwitchButton(
              value: privacy.isReplayAllowed,
              onChanged: (consented) => ref
                  .read(privacyControllerProvider.notifier)
                  .setSessionReplayConsent(consented),
              text: KaziLocalizations.current.privacySessionRecording,
              description:
                  KaziLocalizations.current.privacySessionRecordingDescription,
              icon: Icons.videocam_outlined,
            ),
            SettingsOptionButton(
              onTap: () => KaziNavigator.push(AppPage.privacyPolicy),
              text: KaziLocalizations.current.privacyPolicy,
              icon: Icons.policy_outlined,
            ),
          ],
        ),
        SettingsGroup(
          title: KaziLocalizations.current.about,
          children: [
            SettingsOptionButton(
              onTap: onRateApp,
              text: KaziLocalizations.current.rateApp,
              icon: Icons.star_outline,
            ),
            // Topics that open the real functions, not a replay of the setup:
            // re-running it on a configured app helps nobody.
            SettingsOptionButton(
              onTap: () => KaziNavigator.push(AppPage.howToUse),
              text: KaziLocalizations.current.howToUseKazi,
              icon: Icons.help_outline,
            ),
            SettingsOptionButton(
              // Destructive, so it is isolated at the end and marked in red.
              onTap: () => showSignOutDialog(context, ref),
              text: KaziLocalizations.current.signOut,
              icon: Icons.logout,
              isDestructive: true,
            ),
          ],
        ),
        // Debug only, so the label is not translated: this row never ships.
        if (kDebugMode)
          SettingsGroup(
            title: 'Debug',
            children: [
              SettingsOptionButton(
                onTap: () => KaziNavigator.push(AppPage.themeGallery),
                text: 'Design tokens',
                icon: Icons.palette_outlined,
              ),
              SettingsOptionButton(
                onTap: () => _resetGuidedSetup(context, ref),
                text: 'Reset guided setup',
                icon: Icons.restart_alt,
              ),
            ],
          ),
      ],
    );
  }

  /// Clears every trace of the onboarding — server stamps, checklist steps and
  /// local hint flags — so the flow can run again on the same account. The
  /// catalog and services are left in place, which is how the stalled segment
  /// is tested: reset, then reopen with data already there.
  static Future<void> _resetGuidedSetup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final userId = ref.read(authServiceProvider).user?.uid;
    if (userId == null) return;

    await ref.read(userSettingsRepositoryProvider).resetOnboardingForDebug(
      userId,
    );

    final storage = await ref.read(localStorageProvider.future);
    for (final hint in OnboardingHint.values) {
      await storage.remove(hint.storageKey);
    }
    await storage.remove(StorageKeys.whatsNewSeenVersion);

    ref
      ..invalidate(onboardingControllerProvider)
      ..invalidate(checklistControllerProvider)
      ..invalidate(activeUserNudgesControllerProvider);

    if (context.mounted) {
      KaziSnackbar.show(context, 'Guided setup reset. Restart the app.');
    }
  }

  /// Listed in their own language, never translated into the active one:
  /// someone in the wrong locale has to recognise their own.
  static String _languageLabel(String languageCode) => switch (languageCode) {
    'pt' => 'Português',
    'es' => 'Español',
    _ => 'English',
  };

  static String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => KaziLocalizations.current.themeSystem,
    ThemeMode.light => KaziLocalizations.current.themeLight,
    ThemeMode.dark => KaziLocalizations.current.themeDark,
  };
}
