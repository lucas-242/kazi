import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_filters_page.dart';
import 'package:kazi/features/services/presenter/widgets/order_by_bottom_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceNavbar extends ConsumerWidget {
  const ServiceNavbar({
    super.key,
    required this.dateKey,
    required this.dateController,
  });

  /// Below this many records the list is short enough to read whole, and a
  /// hint about filtering it would be advice nobody needs yet.
  static const int _hintMinimumServices = 5;

  final GlobalKey<FormFieldState<dynamic>> dateKey;
  final TextEditingController dateController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(serviceLandingControllerProvider);
    final serviceController = ref.read(
      serviceLandingControllerProvider.notifier,
    );

    // The same page header the rebranded settings screen uses — there is
    // nothing behind the root of a tab, so no back chevron.
    return SubNavBar(
      title: KaziLocalizations.current.services.capitalize(),
      showBack: false,
      pills: [
        KaziCircularButton(
          onTap: () => showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => OrderByBottomSheet(
              selectedOption: serviceState.selectedOrderBy,
              onPressed: (orderBy) {
                KaziNavigator.pop();
                serviceController.onChangeOrderBy(orderBy);
              },
            ),
          ),
          child: const Icon(Icons.swap_vert, size: 18),
        ),
        KaziSpacings.horizontalXs,
        HintAnchor(
          hint: OnboardingHint.filters,
          // Filters only make sense against a history. Below this many
          // records the screen is short enough to read whole.
          enabled: serviceState.services.length >= _hintMinimumServices,
          child: KaziCircularButton(
            showCircularIndicator: serviceState.didFiltersChange,
            onTap: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (context) => FiltersBottomSheet(
                dateKey: dateKey,
                dateController: dateController,
              ),
            ),
            child: const Icon(Icons.filter_list_alt, size: 18),
          ),
        ),
      ],
    );
  }
}
