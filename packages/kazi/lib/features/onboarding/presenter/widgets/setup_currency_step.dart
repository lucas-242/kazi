import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Screen 2 — the currency, before any price is typed in it.
///
/// It arrives answered from the device, so for most people it costs one tap.
/// It still gets a screen of its own: for an account with services it is the
/// currency every one of them is stored in, the most consequential answer of
/// the setup.
class SetupCurrencyStep extends ConsumerStatefulWidget {
  const SetupCurrencyStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  ConsumerState<SetupCurrencyStep> createState() => _SetupCurrencyStepState();
}

class _SetupCurrencyStepState extends ConsumerState<SetupCurrencyStep> {
  String _query = '';

  /// The answer the screen opened with goes first, so confirming it needs no
  /// scrolling. Pinned rather than following the selection, or the list would
  /// reorder under the finger.
  late final SupportedCurrency _pinned = widget.state.currency;

  List<SupportedCurrency> get _currencies => [
    if (_pinned.matchesSearch(_query)) _pinned,
    for (final currency in SupportedCurrency.values)
      if (currency != _pinned && currency.matchesSearch(_query)) currency,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final state = widget.state;
    final controller = ref.read(guidedSetupControllerProvider.notifier);
    final currencies = _currencies;

    return SetupScaffold(
      flow: state.flow,
      step: SetupStep.currency,
      onBack: controller.back,
      resizesForKeyboard: true,
      title: l10n.setupCurrencyTitle,
      subtitle: state.hasExistingServices
          // Confirming the currency labels every service already registered.
          ? l10n.setupEssentialsCurrencyNote
          : l10n.setupCurrencySubtitle,
      actionLabel: l10n.setupContinue,
      onAction: controller.goToNextStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaziTextFormField(
            labelText: l10n.search,
            hintText: l10n.search,
            prefixIcon: const Icon(LucideIcons.search),
            onChanged: (value) => setState(() => _query = value),
          ),
          KaziSpacings.verticalMd,
          if (currencies.isEmpty)
            Text(l10n.noResults, style: KaziTextStyles.titleSmall)
          else
            for (final currency in currencies)
              OptionTile(
                label: currency.localizedName,
                detail: '${currency.isoCode} · ${currency.symbol}',
                mark: OptionMark.radio,
                selected: currency == state.currency,
                onTap: () => controller.setCurrency(currency),
              ),
        ],
      ),
    );
  }
}
