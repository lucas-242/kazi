import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_exit.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi/features/settings/presenter/widgets/billing_cycle_editor.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Screen 3 — when the money arrives.
///
/// Getting the cycle wrong at the start contaminates every total the home will
/// ever show, which is why it is asked here, with the same answers as the cycle
/// page, and not left to settings.
class SetupCycleStep extends ConsumerStatefulWidget {
  const SetupCycleStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  ConsumerState<SetupCycleStep> createState() => _SetupCycleStepState();
}

class _SetupCycleStepState extends ConsumerState<SetupCycleStep> {
  /// False while a custom interval is not a valid answer; the state keeps the
  /// last valid cycle meanwhile.
  bool _isCycleValid = true;

  GuidedSetupController get _controller =>
      ref.read(guidedSetupControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final state = widget.state;
    final essentials = state.flow == SetupFlow.essentials;
    final isSaving = state.status == BaseStateStatus.loading;

    return SetupScaffold(
      flow: state.flow,
      step: SetupStep.cycle,
      onBack: _controller.back,
      // The custom cycle types its interval on this screen.
      resizesForKeyboard: true,
      title: l10n.setupCycleTitle,
      subtitle: l10n.setupCycleSubtitle,
      actionLabel: essentials ? l10n.finish : l10n.setupContinue,
      onAction: !_isCycleValid || isSaving
          ? null
          : essentials
          ? _finish
          : _controller.goToNextStep,
      child: BillingCycleEditor(
        initial: state.billingCycle,
        onChanged: (cycle) {
          setState(() => _isCycleValid = cycle != null);
          if (cycle != null) _controller.setBillingCycle(cycle);
        },
      ),
    );
  }

  /// The essentials flow ends here: an account that already has services has
  /// no first number to be shown.
  Future<void> _finish() async {
    await _controller.complete(registerService: false);

    final result = ref.read(guidedSetupControllerProvider).asData?.value;
    if (result?.status == BaseStateStatus.success && mounted) {
      leaveSetup(context, result!);
    }
  }
}
