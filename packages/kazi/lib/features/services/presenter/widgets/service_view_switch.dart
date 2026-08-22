import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The List / Summary switch. Both sides answer the same question over the
/// same filtered services; see README.md.
class ServiceViewSwitch extends ConsumerWidget {
  const ServiceViewSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(
      serviceLandingControllerProvider.select((state) => state.view),
    );
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    return Row(
      spacing: KaziInsets.xs,
      children: [
        KaziChip(
          label: KaziLocalizations.current.list,
          isSelected: view == ServiceView.list,
          onTap: () => controller.onChangeView(ServiceView.list),
        ),
        HintAnchor(
          hint: OnboardingHint.summary,
          // Pointless while the summary is open, or with nothing in it.
          enabled: view != ServiceView.summary,
          child: KaziChip(
            label: KaziLocalizations.current.summary,
            isSelected: view == ServiceView.summary,
            onTap: () => controller.onChangeView(ServiceView.summary),
          ),
        ),
      ],
    );
  }
}
