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
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: KaziInsets.lg,
                  right: KaziInsets.lg,
                  top: KaziInsets.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120.0,
                      height: 120.0,
                      child: CircleAvatar(
                        backgroundImage: user.thereIsPhoto
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        backgroundColor: KaziColors.white,
                        child: user.photoUrl == null
                            ? Text(
                                '🦆',
                                style: KaziTextStyles.titleMd.copyWith(
                                  color: context.colorsScheme.surface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 80,
                                ),
                              )
                            : null,
                      ),
                    ),
                    KaziSpacings.verticalLg,
                    Text(user.name, style: KaziTextStyles.titleMd),
                    KaziSpacings.verticalXLg,
                    Row(
                      children: [
                        Text(
                          KaziLocalizations.current.email,
                          style: KaziTextStyles.titleSm,
                        ),
                      ],
                    ),

                    Row(children: [Text(user.email, style: KaziTextStyles.md)]),
                    KaziSpacings.verticalLg,
                    const Divider(),
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
