import 'package:flutter/widgets.dart';
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
    final hasSomethingToSummarize = ref.watch(
      serviceLandingControllerProvider.select(
        (state) => !state.hasNothingToShow,
      ),
    );
    final controller = ref.read(serviceLandingControllerProvider.notifier);

    return KaziSegmentedControl<ServiceView>(
      selected: view,
      onChanged: controller.onChangeView,
      segments: [
        KaziSegment(
          value: ServiceView.list,
          label: KaziLocalizations.current.list,
        ),
        KaziSegment(
          value: ServiceView.summary,
          label: KaziLocalizations.current.summary,
          wrap: (segment) => HintAnchor(
            hint: OnboardingHint.summary,
            radius: KaziRadii.xs,
            // Pointless while the summary is open, or with nothing in it.
            enabled: view != ServiceView.summary && hasSomethingToSummarize,
            child: segment,
          ),
        ),
      ],
    );
  }
}
