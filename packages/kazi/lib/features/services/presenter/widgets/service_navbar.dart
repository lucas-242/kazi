import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/pages/service_filters_page.dart';
import 'package:kazi/features/services/presenter/widgets/order_by_bottom_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
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

    return SubNavBar(
      title: KaziLocalizations.current.services.capitalize(),
      showBack: false,
      showDivider: false,
      pills: [
        KaziCircularButton.plain(
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
        HintAnchor(
          hint: OnboardingHint.filters,
          enabled: serviceState.services.length >= _hintMinimumServices,
          child: KaziCircularButton.plain(
            showCircularIndicator: serviceState.hasActiveFilters,
            onTap: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (context) => FiltersBottomSheet(
                dateKey: dateKey,
                dateController: dateController,
              ),
            ),
            child: const Icon(Icons.filter_alt_outlined, size: 18),
          ),
        ),
      ],
    );
  }
}
