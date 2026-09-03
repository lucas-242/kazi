import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/widgets/quick_add_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Quick-add sheet to create a catalog item without leaving the service form.
/// On success the new item is appended to the form's dropdown (no refetch) and
/// auto-selected; validation/creation errors are shown as a snackbar.
///
/// Three fields, because the sheet exists to unblock a registration rather
/// than to be the catalog screen: anything else about the item is edited
/// there, later.
class AddCatalogItemSheet extends ConsumerStatefulWidget {
  const AddCatalogItemSheet({super.key, required this.service});

  /// The service that keys the [serviceFormControllerProvider] family.
  final Service? service;

  @override
  ConsumerState<AddCatalogItemSheet> createState() =>
      _AddCatalogItemSheetState();
}

class _AddCatalogItemSheetState extends ConsumerState<AddCatalogItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _valueKey = GlobalKey<FormFieldState>();
  final _commissionKey = GlobalKey<FormFieldState>();
  final _nameController = TextEditingController();
  late final MoneyMaskedTextController _valueController;
  late final MoneyMaskedTextController _commissionController;
  Color? _color;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The item is saved with the user's default currency, so the mask has to
    // show that currency: a device-locale symbol would label the amount with a
    // currency it is not stored in.
    final currency = ref.read(kaziDefaultCurrencyProvider);
    _valueController = MoneyMaskedTextController(
      leftSymbol: '${currency.symbol} ',
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      precision: currency.decimalDigits,
    );
    _commissionController = MoneyMaskedTextController(
      // Full commission until told otherwise: an item left untouched must be
      // worth all of its value, which is what "no commission" means in money.
      initialValue: 100,
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      rightSymbol: '%',
      precision: 1,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = serviceFormControllerProvider(service: widget.service);
    try {
      await ref
          .read(provider.notifier)
          .quickAddCatalogItem(
            name: _nameController.text,
            defaultValue: _valueController.numberValue,
            commissionPercent: _commissionController.numberValue,
            color: _color,
          );
      if (mounted) KaziNavigator.pop();
    } on AppError catch (exception) {
      if (mounted) {
        setState(() => _saving = false);
        KaziSnackbar.show(context, exception.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return QuickAddSheet(
      title: l10n.newCatalogItem,
      formKey: _formKey,
      isSaving: _saving,
      onConfirm: _onConfirm,
      children: [
        KaziFieldInput(
          fieldKey: _nameKey,
          label: l10n.name,
          controller: _nameController,
          autofocus: true,
          validator: (value) =>
              FormValidator.validateTextField(value, l10n.name),
        ),
        KaziSpacings.verticalXs,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: KaziFieldInput(
                fieldKey: _valueKey,
                label: l10n.defaultPrice,
                controller: _valueController,
                keyboardType: TextInputType.number,
                validator: (value) => FormValidator.validateNumberField(
                  _valueController.numberValue.toString(),
                  l10n.defaultPrice,
                ),
              ),
            ),
            KaziSpacings.horizontalXs,
            Expanded(
              child: KaziFieldInput(
                fieldKey: _commissionKey,
                label: l10n.commission,
                controller: _commissionController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) => FormValidator.validateNumberField(
                  _commissionController.numberValue.toString(),
                  l10n.commission,
                ),
              ),
            ),
          ],
        ),
        KaziSpacings.verticalMd,
        KaziFieldCaption(l10n.colorSwipeAll),
        KaziSpacings.verticalXs,
        // One scrolling row rather than a grid: eighteen colours in a grid grow
        // the sheet by three rows and push the button off screen.
        KaziColorSwatchPicker(
          selected: _color,
          isScrollable: true,
          onChanged: (color) => setState(() => _color = color),
        ),
      ],
    );
  }
}
