import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/kazi_money_masked_text_controller.dart';
import 'package:kazi/features/onboarding/domain/models/setup_catalog_item.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/services/presenter/widgets/quick_add_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Edits one catalog line — or adds a new one — over the list itself.
///
/// A sheet rather than a screen: the point of the catalog step is that it is
/// one surface you correct in place. Sending someone to another page to fix a
/// price turns two taps into a journey.
Future<void> openSetupItemSheet(
  BuildContext context,
  WidgetRef ref, {
  required SupportedCurrency currency,
  SetupCatalogItem? item,
}) => KaziNavigator.showBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _SetupItemSheet(currency: currency, item: item),
);

class _SetupItemSheet extends ConsumerStatefulWidget {
  const _SetupItemSheet({required this.currency, this.item});

  final SupportedCurrency currency;
  final SetupCatalogItem? item;

  @override
  ConsumerState<_SetupItemSheet> createState() => _SetupItemSheetState();
}

class _SetupItemSheetState extends ConsumerState<_SetupItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final KaziMoneyMaskedTextController _valueController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _valueController = KaziMoneyMaskedTextController(
      initialValue: widget.item?.value ?? 0,
      leftSymbol: '${widget.currency.symbol} ',
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      precision: widget.currency.decimalDigits,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(guidedSetupControllerProvider.notifier);
    final name = _nameController.text.trim();

    // Zero means "not priced", not "free": the mask cannot express an empty
    // amount, and a service worth nothing is not a thing anyone sells.
    final raw = _valueController.numberValue;
    final value = raw <= 0 ? null : raw;

    final item = widget.item;
    if (item == null) {
      controller.addItem(name: name, value: value);
    } else {
      controller.editItem(item.id, name: name, value: value);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final item = widget.item;

    return QuickAddSheet(
      title: item?.name ?? l10n.setupCatalogAddAnother,
      formKey: _formKey,
      confirmLabel: l10n.save,
      onConfirm: _save,
      children: [
        KaziFieldInput(
          label: l10n.setupPriceSheetName,
          controller: _nameController,
          autofocus: item == null,
          validator: (value) =>
              FormValidator.validateTextField(value, l10n.setupPriceSheetName),
        ),
        KaziSpacings.verticalXs,
        KaziFieldInput(
          label: l10n.setupPriceSheetValue,
          controller: _valueController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofocus: item != null,
        ),
      ],
    );
  }
}
