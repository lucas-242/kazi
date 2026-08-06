import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_controller.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_state.dart';
import 'package:kazi/features/subscription/presenter/widgets/plan_comparison.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class PaywallView extends ConsumerWidget {
  const PaywallView({super.key, this.limit});

  /// When set, shows a "limit reached" header tailored to what was blocked.
  final LimitType? limit;

  String _limitTitle(KaziLocalizations l10n) {
    switch (limit!) {
      case LimitType.serviceType:
        return l10n.limitReachedTypesTitle;
      case LimitType.servicesPerMonth:
        return l10n.limitReachedServicesTitle;
      case LimitType.clients:
        return l10n.limitReachedClientsTitle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;

    ref.listen(paywallControllerProvider, (previous, next) {
      final state = next.asData?.value;
      if (state == null) return;
      if (state.didPurchase) {
        Navigator.of(context).pop();
      } else if (state.status == BaseStateStatus.error &&
          state.callbackMessage.isNotEmpty) {
        KaziSnackbar.show(context, state.callbackMessage);
      }
    });

    final asyncState = ref.watch(paywallControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 28,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
      ),
      body: KaziSafeArea(
        isLoading: asyncState.isLoading,
        child: asyncState.when(
          loading: () => _Content(
            l10n: l10n,
            title: _title(l10n),
            subtitle: _subtitle(l10n),
          ),
          error: (_, _) => _Content(
            l10n: l10n,
            title: _title(l10n),
            subtitle: _subtitle(l10n),
          ),
          data: (state) => _Content(
            l10n: l10n,
            title: _title(l10n),
            subtitle: _subtitle(l10n),
            state: state,
            onSubscribe: ref.read(paywallControllerProvider.notifier).subscribe,
            onRestore: ref.read(paywallControllerProvider.notifier).restore,
          ),
        ),
      ),
    );
  }

  String _title(KaziLocalizations l10n) =>
      limit != null ? _limitTitle(l10n) : l10n.paywallTitle;

  String _subtitle(KaziLocalizations l10n) =>
      limit != null ? l10n.limitReachedSubtitle : l10n.paywallSubtitle;
}

class _Content extends StatelessWidget {
  const _Content({
    required this.l10n,
    required this.title,
    required this.subtitle,
    this.state,
    this.onSubscribe,
    this.onRestore,
  });

  final KaziLocalizations l10n;
  final String title;
  final String subtitle;
  final PaywallState? state;
  final VoidCallback? onSubscribe;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final isProcessing = state?.isProcessing ?? false;
    final isTrialEligible = state?.isTrialEligible ?? false;
    final price = state?.priceString;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: KaziTextStyles.titleLg, textAlign: TextAlign.center),
        KaziSpacings.verticalSm,
        Text(subtitle, style: KaziTextStyles.md, textAlign: TextAlign.center),
        KaziSpacings.verticalXLg,
        const PlanComparison(),
        KaziSpacings.verticalXLg,
        if (price != null) ...[
          Text(
            isTrialEligible
                ? l10n.paywallTrialThenPrice(price)
                : l10n.paywallPricePerMonth(price),
            style: KaziTextStyles.titleMd,
            textAlign: TextAlign.center,
          ),
          KaziSpacings.verticalSm,
        ],
        KaziElevatedButton.label(
          onTap: isProcessing ? null : onSubscribe,
          label: isProcessing
              ? '...'
              : (isTrialEligible
                    ? l10n.paywallStartTrial
                    : l10n.paywallSubscribe),
        ),
        KaziSpacings.verticalSm,
        if (onRestore != null)
          KaziTextButton(
            onTap: isProcessing ? () {} : onRestore!,
            child: Text(l10n.paywallRestore),
          ),
        KaziSpacings.verticalSm,
        Text(
          l10n.paywallRenewInfo,
          style: KaziTextStyles.sm,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
