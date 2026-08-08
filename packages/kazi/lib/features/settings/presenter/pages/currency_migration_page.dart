import 'package:flutter/material.dart';
import 'package:kazi/features/settings/presenter/controllers/currency_migration_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// One-time question for users whose services predate multi-currency support.
///
/// It blocks rather than nags: until the app knows which currency those amounts
/// are in, every balance behind it is a sum of unlike quantities.
class CurrencyMigrationPage extends ConsumerStatefulWidget {
  const CurrencyMigrationPage({super.key});

  @override
  ConsumerState<CurrencyMigrationPage> createState() =>
      _CurrencyMigrationPageState();
}

class _CurrencyMigrationPageState extends ConsumerState<CurrencyMigrationPage> {
  SupportedCurrency? _selected;
  String _query = '';

  List<SupportedCurrency> get _filtered =>
      SupportedCurrency.values.where((c) => c.matchesSearch(_query)).toList();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyMigrationControllerProvider);
    final selected = _selected ?? state.suggestedCurrency;
    final currencies = _filtered;

    return PopScope(
      canPop: false,
      child: Scaffold(
        // The fixed chrome (title, description, search, confirm) plus a
        // keyboard leaves the list almost no room if the body shrinks, so let
        // the keyboard overlay the bottom instead — the search field is near
        // the top and stays visible either way.
        resizeToAvoidBottomInset: false,
        backgroundColor: context.colorsScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KaziInsets.xLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KaziSpacings.verticalLg,
                Text(
                  KaziLocalizations.current.currencyMigrationTitle,
                  style: KaziTextStyles.headlineMd,
                ),
                KaziSpacings.verticalSm,
                Text(
                  KaziLocalizations.current.currencyMigrationDescription,
                  style: KaziTextStyles.md,
                ),
                if (state.affectedServices > 0) ...[
                  KaziSpacings.verticalXs,
                  Text(
                    KaziLocalizations.current.currencyMigrationServicesCount(
                      state.affectedServices,
                    ),
                    style: KaziTextStyles.labelMd,
                  ),
                ],
                KaziSpacings.verticalLg,
                KaziTextFormField(
                  labelText: KaziLocalizations.current.search,
                  hintText: KaziLocalizations.current.search,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => setState(() => _query = value),
                ),
                KaziSpacings.verticalMd,
                Expanded(
                  child: currencies.isEmpty
                      ? Center(
                          child: Text(
                            KaziLocalizations.current.noResults,
                            style: KaziTextStyles.titleSm,
                          ),
                        )
                      : ListView.separated(
                          itemCount: currencies.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (_, index) {
                            final currency = currencies[index];
                            return _CurrencyTile(
                              currency: currency,
                              isSelected: currency == selected,
                              onTap: state.isApplying
                                  ? null
                                  : () => setState(() => _selected = currency),
                            );
                          },
                        ),
                ),
                if (state.errorMessage != null) ...[
                  Text(
                    state.errorMessage!,
                    style: KaziTextStyles.labelMd.copyWith(
                      color: context.colorsScheme.error,
                    ),
                  ),
                  KaziSpacings.verticalXs,
                ],
                Text(
                  KaziLocalizations.current.currencyMigrationChangeLater,
                  style: KaziTextStyles.labelSm,
                ),
                KaziSpacings.verticalSm,
                KaziElevatedButton.label(
                  onTap: state.isApplying
                      ? null
                      : () => ref
                            .read(currencyMigrationControllerProvider.notifier)
                            .confirm(selected),
                  label: state.isApplying
                      ? KaziLocalizations.current.currencyMigrationApplying
                      : KaziLocalizations.current.confirm,
                ),
                KaziSpacings.verticalLg,
              ],
            ),
          ),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        '${currency.localizedName} (${currency.symbol})',
        style: isSelected ? KaziTextStyles.titleSm : KaziTextStyles.md,
      ),
      subtitle: Text(currency.isoCode, style: KaziTextStyles.labelSm),
      trailing: Visibility(
        visible: isSelected,
        child: Icon(Icons.check, color: context.colorsScheme.primary),
      ),
      selected: isSelected,
      contentPadding: EdgeInsets.zero,
    );
  }
}
