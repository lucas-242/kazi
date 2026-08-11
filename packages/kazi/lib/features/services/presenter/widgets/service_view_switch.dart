import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The List / Summary switch.
///
/// A switch rather than a second tab: both sides answer the same question over
/// the same filtered services, one row at a time and one total at a time. Made
/// the summary inherit the filters — the most expensive thing to build in a
/// management app — instead of duplicating them on a parallel screen.
class ServiceViewSwitch extends ConsumerWidget {
  const ServiceViewSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(
      serviceLandingControllerProvider.select((state) => state.view),
    );
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    return Row(
      children: [
        KaziChip(
          label: KaziLocalizations.current.list,
          isSelected: view == ServiceView.list,
          onTap: () => controller.onChangeView(ServiceView.list),
        ),
        KaziSpacings.horizontalXs,
        KaziChip(
          label: KaziLocalizations.current.summary,
          isSelected: view == ServiceView.summary,
          onTap: () => controller.onChangeView(ServiceView.summary),
        ),
      ],
    );
  }
}
