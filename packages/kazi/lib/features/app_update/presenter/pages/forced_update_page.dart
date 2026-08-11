import 'package:flutter/material.dart';
import 'package:kazi/features/app_update/presenter/controllers/app_update_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ForcedUpdatePage extends ConsumerWidget {
  const ForcedUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onUpdate() async {
      final storeUrl = ref.read(appUpdateControllerProvider).info.storeUrl;
      if (storeUrl.isEmpty) {
        return;
      }
      await ref.read(kaziUrlLauncherServiceProvider).launch(storeUrl);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KaziInsets.xxLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.system_update,
                  size: 96,
                  color: context.colors.brand.text,
                ),
                KaziSpacings.verticalLg,
                Text(
                  KaziLocalizations.current.forcedUpdateTitle,
                  textAlign: TextAlign.center,
                  style: KaziTextStyles.headlineLarge,
                ),
                KaziSpacings.verticalSm,
                Text(
                  KaziLocalizations.current.forcedUpdateMessage,
                  textAlign: TextAlign.center,
                  style: KaziTextStyles.headlineSmall,
                ),
                KaziSpacings.verticalXxLg,
                KaziElevatedButton.label(
                  onTap: onUpdate,
                  label: KaziLocalizations.current.forcedUpdateButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
