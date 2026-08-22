import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// Lets the user pick the profile default currency
class CurrencyBottomSheet extends ConsumerStatefulWidget {
  const CurrencyBottomSheet({super.key});

  @override
  ConsumerState<CurrencyBottomSheet> createState() =>
      _CurrencyBottomSheetState();
}

class _CurrencyBottomSheetState extends ConsumerState<CurrencyBottomSheet> {
  String _query = '';

  List<SupportedCurrency> get _filtered =>
      SupportedCurrency.values.where((c) => c.matchesSearch(_query)).toList();

  Future<void> _onSelect(SupportedCurrency currency) async {
    await ref
        .read(kaziCurrencyControllerProvider.notifier)
        .selectCurrency(currency);
    if (mounted) KaziNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(kaziDefaultCurrencyProvider);
    final currencies = _filtered;

    // Capped and scrolled internally so the search field stays put instead of
    // scrolling away with the list.
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.height * 0.7),
      child: Padding(
        // Sits inside the height cap, so the keyboard shrinks the list instead
        // of overflowing the sheet.
        padding: EdgeInsets.only(
          top: KaziInsets.xLg,
          left: KaziInsets.xLg,
          right: KaziInsets.xLg,
          bottom: KaziInsets.xxxLg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              KaziLocalizations.current.defaultCurrency,
              style: KaziTextStyles.titleMedium,
            ),
            KaziSpacings.verticalLg,
            KaziTextFormField(
              labelText: KaziLocalizations.current.search,
              hintText: KaziLocalizations.current.search,
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
            KaziSpacings.verticalMd,
            if (currencies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KaziInsets.md),
                child: Text(
                  KaziLocalizations.current.noResults,
                  style: KaziTextStyles.titleSmall,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, index) {
                    final currency = currencies[index];
                    return _CurrencyTile(
                      currency: currency,
                      isSelected: currency == selected,
                      onTap: () => _onSelect(currency),
                    );
                  },
                ),
              ),
          ],
        ),
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
        style: isSelected ? KaziTextStyles.titleSmall : KaziTextStyles.bodyMedium,
      ),
      subtitle: Text(currency.isoCode, style: KaziTextStyles.labelSmall),
      trailing: Visibility(
        visible: isSelected,
        child: Icon(Icons.check, color: context.colors.brand.text),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
