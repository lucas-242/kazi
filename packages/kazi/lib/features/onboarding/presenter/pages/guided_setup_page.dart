import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_catalog_step.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_commission_step.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_currency_step.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_cycle_step.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_first_service_step.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_profession_step.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_result_step.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The guided setup: full screen, no bottom bar, one question per screen.
///
/// Ninety seconds whose only goal is to leave the app **able to calculate** —
/// and then to show the user the first number that comes out of it.
class GuidedSetupPage extends ConsumerWidget {
  const GuidedSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guidedSetupControllerProvider);

    // Errors surface as a snackbar and leave the step where it is: the setup
    // never dead-ends, and a failed write can simply be retried.
    ref.listen(guidedSetupControllerProvider, (_, next) {
      final data = next.asData?.value;
      if (data == null || data.status != BaseStateStatus.error) return;
      KaziSnackbar.show(context, data.callbackMessage);
    });

    final data = state.asData?.value;

    return PopScope(
      // The setup is a gate: the system back steps through the questions and
      // never leaves them. Only a debug preview can be left, from either end.
      canPop:
          data != null && data.isPreview && data.flow.before(data.step) == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(guidedSetupControllerProvider.notifier).back();
      },
      child: state.when(
        loading: () => const _SetupLoading(),
        error: (_, _) => const _SetupLoading(),
        data: _stepFor,
      ),
    );
  }

  Widget _stepFor(GuidedSetupState state) => switch (state.step) {
    SetupStep.profession =>
      state.flow == SetupFlow.full &&
              state.preset == null &&
              state.customProfession.isNotEmpty
          // The typed path detours through the employment question, which is how
          // the commission is answered without naming it.
          ? SetupEmploymentStep(state: state)
          : SetupProfessionStep(state: state),
    SetupStep.catalog => SetupCatalogStep(state: state),
    SetupStep.commission => SetupCommissionStep(state: state),
    SetupStep.currency => SetupCurrencyStep(state: state),
    SetupStep.cycle => SetupCycleStep(state: state),
    SetupStep.firstService => SetupFirstServiceStep(state: state),
    SetupStep.result => SetupResultStep(state: state),
  };
}

class _SetupLoading extends StatelessWidget {
  const _SetupLoading();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.brand.fill,
    body: Center(
      child: CircularProgressIndicator(color: context.colors.brand.onFill),
    ),
  );
}
