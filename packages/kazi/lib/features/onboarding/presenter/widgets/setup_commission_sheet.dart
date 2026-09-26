import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/kazi_money_masked_text_controller.dart';
import 'package:kazi/features/services/presenter/widgets/quick_add_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The answers that cover almost everyone; the sheet's field takes any other.
const List<double> setupCommissionPresets = [30, 40, 50, 100];

/// Asks what the user keeps, as a percentage. A chip answers in one tap; the
/// field takes any value above 0 and up to 100. Resolves to null when dismissed.
///
/// [initial] prefills the field, and should only be an answer the user already
/// gave — never the kit's guess.
Future<double?> openSetupCommissionSheet(
  BuildContext context, {
  required String title,
  double? initial,
}) => KaziNavigator.showBottomSheet<double>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _SetupCommissionSheet(title: title, initial: initial),
);

class _SetupCommissionSheet extends StatefulWidget {
  const _SetupCommissionSheet({required this.title, this.initial});

  final String title;
  final double? initial;

  @override
  State<_SetupCommissionSheet> createState() => _SetupCommissionSheetState();
}

class _SetupCommissionSheetState extends State<_SetupCommissionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final KaziMoneyMaskedTextController _percentController;

  @override
  void initState() {
    super.initState();
    _percentController = KaziMoneyMaskedTextController(
      initialValue: widget.initial ?? 0,
      decimalSeparator: NumberFormatUtils.getDecimalSeparator(),
      thousandSeparator: NumberFormatUtils.getThousandSeparator(),
      rightSymbol: '%',
      precision: 1,
    );
  }

  @override
  void dispose() {
    _percentController.dispose();
    super.dispose();
  }

  String? _validate(String? _) {
    final percent = _percentController.numberValue;
    return percent > 0 && percent <= 100
        ? null
        : KaziLocalizations.current.setupCommissionInvalid;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_percentController.numberValue);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return QuickAddSheet(
      title: widget.title,
      formKey: _formKey,
      confirmLabel: l10n.save,
      onConfirm: _save,
      children: [
        Wrap(
          spacing: KaziInsets.xs,
          runSpacing: KaziInsets.xs,
          children: [
            for (final percent in setupCommissionPresets)
              KaziChip(
                label: NumberFormatUtils.formatPercent(percent),
                isSelected: widget.initial == percent,
                onTap: () => Navigator.of(context).pop(percent),
              ),
          ],
        ),
        KaziSpacings.verticalMd,
        KaziFieldInput(
          label: l10n.setupCommissionField,
          controller: _percentController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: _validate,
        ),
      ],
    );
  }
}
