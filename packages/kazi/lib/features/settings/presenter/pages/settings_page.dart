import 'package:flutter/material.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/settings/presenter/widgets/settings_options.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

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
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(KaziInsets.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          context.colorsScheme.surfaceContainerHigh,
                      foregroundImage: user.thereIsPhoto
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: Text(
                        '🦆',
                        style: KaziTextStyles.titleMd.copyWith(fontSize: 24),
                      ),
                    ),
                    KaziSpacings.horizontalMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: KaziTextStyles.titleSm,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: KaziTextStyles.support.copyWith(
                              color: context.colorsScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SettingsOptions(onRateApp: onRateApp),
            ],
          ),
        ),
      ),
    );
  }
}
