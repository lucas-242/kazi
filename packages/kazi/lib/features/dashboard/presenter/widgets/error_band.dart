import 'package:flutter/material.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A failed read, reported above the content instead of replacing it — the
/// cycle total keeps the last value it knew. See README.md.
class ErrorBand extends ConsumerWidget {
  const ErrorBand({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.danger.surface,
        borderRadius: KaziRadii.lgBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message.isEmpty
                  ? KaziLocalizations.current.errorToGetServices
                  : message,
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.danger.onSurface,
              ),
            ),
          ),
          KaziSpacings.horizontalSm,
          KaziTextButton(
            onTap: ref.read(dashboardControllerProvider.notifier).onRefresh,
            color: colors.danger.onSurface,
            child: Text(KaziLocalizations.current.tryAgain),
          ),
        ],
      ),
    );
  }
}
