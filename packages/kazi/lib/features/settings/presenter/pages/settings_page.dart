import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_options.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
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
            SubNavBar(title: KaziLocalizations.current.menu, showBack: false),
            KaziSpacings.verticalMd,
            _ProfileRow(user: user),
            SettingsOptions(onRateApp: onRateApp),
            KaziSpacings.verticalLg,
          ],
        ),
      ),
    );
  }
}

/// Who is signed in. Shaped like the option rows below it, but inert: the
/// account is stated, not configured.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          CircleAvatar(
            radius: 22,
            backgroundColor: colors.surfaceMuted,
            foregroundImage: user.thereIsPhoto
                ? NetworkImage(user.photoUrl!)
                : null,
            child: Icon(Icons.person_outline, color: colors.textMuted),
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
