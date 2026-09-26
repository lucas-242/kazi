import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class OptionalUpdateDialog extends ConsumerWidget {
  const OptionalUpdateDialog({super.key, required this.storeUrl});

  final String storeUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KaziDialog(
      title: KaziLocalizations.current.optionalUpdateTitle,
      message: KaziLocalizations.current.optionalUpdateMessage,
      cancelText: KaziLocalizations.current.updateLater,
      confirmText: KaziLocalizations.current.updateNow,
      onCancel: KaziNavigator.pop,
      onConfirm: () async {
        KaziNavigator.pop();
        if (storeUrl.isNotEmpty) {
          await ref.read(kaziUrlLauncherServiceProvider).launch(storeUrl);
        }
      },
    );
  }
}
