import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The screen the whole setup exists to reach.
///
/// It does not congratulate the app. "All set, enjoy Kazi!" talks about us;
/// "R$ 81.00 is yours" talks about them — and it is the only argument that
/// brings someone back tomorrow.
class SetupResultStep extends StatelessWidget {
  const SetupResultStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final colors = context.colors;

    return SetupScaffold(
      step: SetupStep.result,
      showProgress: false,
      backgroundColor: colors.brand.fill,
      foregroundColor: colors.brand.onFill,
      title: '',
      action: KaziElevatedButton.label(
        label: l10n.setupResultCta,
        onTap: () => KaziNavigator.navigate(AppPage.home),
      ),
      child: SizedBox(
        width: double.infinity,
        child: state.hasRegisteredService
            ? _RegisteredResult(state: state)
            : const _ReadyResult(),
      ),
    );
  }
}

class _RegisteredResult extends StatelessWidget {
  const _RegisteredResult({required this.state});

  final GuidedSetupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final onFill = context.colors.brand.onFill;
    final commission = state.registeredCommission ?? 0;
    final total = state.registeredValue ?? 0;
    final percent = total == 0 ? 0.0 : commission / total * 100;

    return Column(
      children: [
        KaziSpacings.verticalXxLg,
        Text(
          l10n.setupResultLabel.toUpperCase(),
          style: KaziTextStyles.tag.copyWith(
            color: onFill.withValues(alpha: 0.7),
          ),
        ),
        KaziSpacings.verticalSm,
        FittedBox(
          child: Text(
            NumberFormatUtils.formatCurrencyIn(commission, state.currency),
            style: KaziTextStyles.amount.copyWith(color: onFill),
          ),
        ),
        KaziSpacings.verticalXs,
        Text(
          l10n.setupResultYours,
          style: KaziTextStyles.titleMedium.copyWith(color: onFill),
        ),
        KaziSpacings.verticalXs,
        Text(
          l10n.setupResultBreakdown(
            NumberFormatUtils.formatCurrencyIn(total, state.currency),
            NumberFormatUtils.formatPercent(percent.roundToDouble()),
          ),
          textAlign: TextAlign.center,
          style: KaziTextStyles.bodySmall.copyWith(
            color: onFill.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// For someone who has not worked yet. The home they land on is still not the
/// empty one this flow set out to remove: the catalog is built, so it has a
/// sentence and a target instead of a zero and nothing to do.
class _ReadyResult extends StatelessWidget {
  const _ReadyResult();

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final onFill = context.colors.brand.onFill;

    return Column(
      children: [
        KaziSpacings.verticalXxLg,
        Text(
          l10n.setupResultReadyTitle,
          textAlign: TextAlign.center,
          style: KaziTextStyles.headlineSmall.copyWith(color: onFill),
        ),
        KaziSpacings.verticalXs,
        Text(
          l10n.setupResultReadySubtitle,
          textAlign: TextAlign.center,
          style: KaziTextStyles.bodyMedium.copyWith(
            color: onFill.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
