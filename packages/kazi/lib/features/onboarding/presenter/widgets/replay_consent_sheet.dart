import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/settings/presenter/controllers/privacy_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The one time the app asks to record sessions.
///
/// Placed at the end of the guided setup, on the screen that has just shown
/// someone their first number — not on first launch. Asked before any value is
/// delivered, this reads as a stranger asking for the keys; asked here, it
/// reads as a favour returned, and the people who say yes are the ones whose
/// sessions are actually worth watching.
///
/// It states the masking plainly, because the masking is the only reason the
/// answer can honestly be yes.
class ReplayConsentSheet extends ConsumerWidget {
  const ReplayConsentSheet({super.key});

  /// Asks, if it has not been asked before, and records whatever comes back.
  ///
  /// Returns when the question is settled, so callers can chain a navigation
  /// after it. Dismissing the sheet by dragging it away is deliberately **not**
  /// taken as a no: an accidental swipe should leave the question open for the
  /// menu, not silently answer it.
  static Future<void> askIfNeeded(BuildContext context, WidgetRef ref) async {
    final settings = await ref.read(privacyControllerProvider.future);
    if (!settings.needsReplayPrompt) return;
    if (!context.mounted) return;

    final consented = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const ReplayConsentSheet(),
    );

    if (consented == null) return;
    await ref
        .read(privacyControllerProvider.notifier)
        .setSessionReplayConsent(consented);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(KaziInsets.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.videocam_outlined,
            size: KaziSizings.iconLg,
            color: colors.brand.text,
          ),
          KaziSpacings.verticalSm,
          Text(l10n.replayConsentTitle, style: context.text.titleLarge),
          KaziSpacings.verticalSm,
          Text(
            l10n.replayConsentBody,
            style: KaziTextStyles.bodyMedium.copyWith(color: colors.textMuted),
          ),
          KaziSpacings.verticalSm,
          // The full policy, one tap away from the question rather than from a
          // menu the person has not seen yet.
          KaziTextButton(
            onTap: () => KaziNavigator.push(AppPage.privacyPolicy),
            child: Text(l10n.privacyPolicy),
          ),
          KaziSpacings.verticalMd,
          KaziElevatedButton.label(
            label: l10n.replayConsentAccept,
            width: double.infinity,
            onTap: () => Navigator.of(context).pop(true),
          ),
          KaziSpacings.verticalXs,
          KaziElevatedButton.outlined(
            label: l10n.replayConsentDecline,
            width: double.infinity,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
