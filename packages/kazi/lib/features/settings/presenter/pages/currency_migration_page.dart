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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyMigrationControllerProvider);
    final selected = _selected ?? state.suggestedCurrency;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                Expanded(
                  child: ListView.separated(
                    itemCount: SupportedCurrency.values.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, index) {
                      final currency = SupportedCurrency.values[index];
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
