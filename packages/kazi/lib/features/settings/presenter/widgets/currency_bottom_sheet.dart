import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// Lets the user pick the profile default currency
class CurrencyBottomSheet extends ConsumerWidget {
  const CurrencyBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(kaziDefaultCurrencyProvider);

    Future<void> onSelect(SupportedCurrency currency) async {
      await ref
          .read(kaziCurrencyControllerProvider.notifier)
          .selectCurrency(currency);
      if (context.mounted) KaziNavigator.pop();
    }

    return SingleChildScrollView(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: KaziInsets.xLg,
              left: KaziInsets.xLg,
              right: KaziInsets.xLg,
              bottom: KaziInsets.xxxLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  KaziLocalizations.current.defaultCurrency,
                  style: KaziTextStyles.titleMd,
                ),
                KaziSpacings.verticalXLg,
                for (final currency in SupportedCurrency.values) ...[
                  _CurrencyTile(
                    currency: currency,
                    isSelected: currency == selected,
                    onTap: () => onSelect(currency),
                  ),
                  if (currency != SupportedCurrency.values.last)
                    const Divider(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  final SupportedCurrency currency;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        '${currency.localizedName} (${currency.symbol})',
        style: isSelected ? KaziTextStyles.titleMd : KaziTextStyles.md,
      ),
      subtitle: Text(currency.isoCode, style: KaziTextStyles.labelSm),
      trailing: Visibility(
        visible: isSelected,
        child: Icon(Icons.check, color: context.colorsScheme.primary),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

extension on SupportedCurrency {
  String get localizedName {
    final l10n = KaziLocalizations.current;
    switch (this) {
      case SupportedCurrency.brl:
        return l10n.currencyBRL;
      case SupportedCurrency.usd:
        return l10n.currencyUSD;
      case SupportedCurrency.cad:
        return l10n.currencyCAD;
      case SupportedCurrency.ngn:
        return l10n.currencyNGN;
      case SupportedCurrency.kes:
        return l10n.currencyKES;
      case SupportedCurrency.ugx:
        return l10n.currencyUGX;
      case SupportedCurrency.pyg:
        return l10n.currencyPYG;
      case SupportedCurrency.inr:
        return l10n.currencyINR;
    }
  }
}
