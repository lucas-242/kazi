import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/onboarding/domain/preset_catalog.dart';
import 'package:kazi/features/settings/presenter/controllers/user_profession_controller.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_options.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

/// The Menu tab — "how does the app work for me?".
///
/// It answers with three groups and nothing else: no numbers, no FAB (see
/// `AppShell`: configuration is not creation), and no shortcut promoted to the
/// header. Anything consulted daily belongs to one of the other three tabs.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(kaziEffectiveLocaleProvider);

    final AppUser user = ref.read(authServiceProvider).user!;

    Future<void> onRateApp() async {
      await ref.read(inAppReviewServiceProvider).requestReview();
    }

    return Scaffold(
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubNavBar(
              title: KaziLocalizations.current.settings,
              showBack: false,
            ),
            _ProfileRow(user: user),
            SettingsOptions(onRateApp: onRateApp),
            const _VersionFooter(),
            KaziSpacings.verticalLg,
          ],
        ),
      ),
    );
  }
}

/// The last line of the menu, and the only place the installed version is
/// stated. Renders nothing until it is known, rather than reserving a hole.
class _VersionFooter extends ConsumerWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(kaziAppVersionProvider).asData?.value;
    if (version == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.lg),
      child: Center(
        child: Text(
          KaziLocalizations.current.appVersionFooter(
            version,
            DateTime.now().year.toString(),
          ),
          style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
        ),
      ),
    );
  }
}

/// Who is signed in and what they do. Shaped like the option rows below it,
/// but inert: the account is stated, not configured.
class _ProfileRow extends ConsumerWidget {
  const _ProfileRow({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final stored = ref.watch(userProfessionProvider).asData?.value;
    final profession = stored == null
        ? null
        : PresetCatalog.displayName(stored);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: KaziRadii.smBorder,
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(KaziInsets.md),
      child: Row(
        children: [
          KaziAvatar(
            name: user.name,
            imageUrl: user.thereIsPhoto ? user.photoUrl : null,
            radius: 22,
          ),
          KaziSpacings.horizontalSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: KaziTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (profession != null)
                  Text(
                    profession,
                    style: KaziTextStyles.bodySmall.copyWith(
                      color: colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  user.email,
                  style: KaziTextStyles.labelSmall.copyWith(
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
