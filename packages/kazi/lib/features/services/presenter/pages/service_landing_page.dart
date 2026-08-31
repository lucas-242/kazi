import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/widgets/service_landing_content.dart';
import 'package:kazi/features/services/presenter/widgets/service_navbar.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:kazi_core/kazi_core.dart';

class ServiceLandingPage extends ConsumerStatefulWidget {
  const ServiceLandingPage({super.key});

  @override
  ConsumerState<ServiceLandingPage> createState() => _ServiceLandingPageState();
}

class _ServiceLandingPageState extends ConsumerState<ServiceLandingPage> {
  final dateKey = GlobalKey<FormFieldState>();
  final dateController = MaskedTextController(
    text: 'dd/MM/yyyy - dd/MM/yyyy',
    mask: '00/00/0000 - 00/00/0000',
  );

  @override
  void initState() {
    super.initState();
    final controller = ref.read(serviceLandingControllerProvider.notifier);
    final state = ref.read(serviceLandingControllerProvider);
    dateController.text =
        '${DateFormat.yMd().format(state.startDate).normalizeDate()} - ${DateFormat.yMd().format(state.endDate).normalizeDate()}';
    Future.microtask(controller.onInit);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ServiceLandingState>(serviceLandingControllerProvider, (
      previous,
      current,
    ) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(serviceLandingControllerProvider);
    final isEmpty = state.status == BaseStateStatus.noData;

    return Scaffold(
      body: KaziSafeArea(
        isScrollView: !isEmpty,
        isLoading: state.status == BaseStateStatus.loading,
        onRefresh: () =>
            ref.read(serviceLandingControllerProvider.notifier).onRefresh(),
        child: state.when(
          onState: (_) => ServiceLandingContent(
            state: state,
            dateController: dateController,
            dateKey: dateKey,
          ),
          onLoading: () => state.services.isEmpty
              ? const SizedBox.shrink()
              : ServiceLandingContent(
                  state: state,
                  dateController: dateController,
                  dateKey: dateKey,
                ),
          onNoData: () => Column(
            children: [
              ServiceNavbar(dateKey: dateKey, dateController: dateController),
              Expanded(
                child: KaziEmpty(
                  message: KaziLocalizations.current.noServices,
                  scrollable: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
