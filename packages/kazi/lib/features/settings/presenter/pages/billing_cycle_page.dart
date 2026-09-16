import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/features/settings/presenter/widgets/billing_cycle_l10n.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Lets the user say when they actually get paid.
///
/// A full page rather than a bottom sheet: the anchor picker is itself a sheet,
/// and stacking one on another is where this stops behaving on small screens.
class BillingCyclePage extends ConsumerStatefulWidget {
  const BillingCyclePage({super.key});

  @override
  ConsumerState<BillingCyclePage> createState() => _BillingCyclePageState();
}

class _BillingCyclePageState extends ConsumerState<BillingCyclePage> {
  static const _quickDays = [1, 5, 10, 15, 20, 25];

  /// Seeded from the stored cycle, then edited locally so the preview can
  /// update on every tap without a write per keystroke.
  late BillingCycleType _type;
  late int _monthDay;
  late int _weekday;
  late DateTime _anchorDate;
  late final TextEditingController _intervalController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(billingCycleProvider);
    _type = current.type;
    _monthDay = switch (current) {
      MonthlyCycle(:final anchorDay) => anchorDay,
      FortnightlyCycle(:final anchorDay) => anchorDay,
      WeeklyCycle() || CustomCycle() => BillingCycle.lastDayAnchor,
    };
    _weekday = switch (current) {
      WeeklyCycle(:final anchorWeekday) => anchorWeekday,
      _ => DateTime.friday,
    };
    _anchorDate = switch (current) {
      CustomCycle(:final anchorDate) => anchorDate,
      _ => _today,
    };
    _intervalController = TextEditingController(
      text: switch (current) {
        CustomCycle(:final intervalDays) => '$intervalDays',
        _ => '',
      },
    );
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  DateTime get _today {
    final now = ref.read(timeServiceProvider).now;
    return DateTime(now.year, now.month, now.day);
  }

  /// Null while the typed interval is empty or out of range.
  int? get _intervalDays {
    final days = int.tryParse(_intervalController.text);
    return days != null && CustomCycle.isValidInterval(days) ? days : null;
  }

  /// Null when the custom interval is not a valid answer yet.
  BillingCycle? get _draft => switch (_type) {
    BillingCycleType.monthly => MonthlyCycle(anchorDay: _monthDay),
    BillingCycleType.fortnightly => FortnightlyCycle(anchorDay: _monthDay),
    BillingCycleType.weekly => WeeklyCycle(anchorWeekday: _weekday),
    BillingCycleType.custom => switch (_intervalDays) {
      final int days => CustomCycle(
        intervalDays: days,
        anchorDate: _anchorDate,
      ),
      null => null,
    },
  };

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final colors = context.colors;
    final draft = _draft;

    return Scaffold(
      appBar: KaziAppBar(title: l10n.billingCycle),
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.billingCycleDescription,
              style: KaziTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                height: 24 / 15,
                color: colors.textMuted,
              ),
            ),
            KaziSpacings.verticalLg,
            for (final type in BillingCycleType.values)
              OptionTile(
                label: type.label,
                selected: _type == type,
                mark: OptionMark.radio,
                detail: _frequencyLabel(type),
                onTap: () => setState(() => _type = type),
              ),
            KaziSpacings.verticalMd,
            if (_type == BillingCycleType.custom)
              ..._buildCustomFields(context)
            else
              ..._buildPayoutDays(context),
            if (draft != null) ...[
              KaziSpacings.verticalLg,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(KaziInsets.sm),
                decoration: BoxDecoration(
                  color: colors.success.surface,
                  borderRadius: KaziRadii.smBorder,
                  border: Border.all(color: colors.success.surfaceBorder),
                ),
                child: Text(
                  _preview(context, draft),
                  style: KaziTextStyles.labelSmall.copyWith(
                    color: colors.success.onSurface,
                  ),
                ),
              ),
            ],
            KaziSpacings.verticalLg,
          ],
        ),
      ),
      bottomNavigationBar: KaziFormFooter(
        label: l10n.billingCycleSave,
        onTap: _isSaving || draft == null ? null : () => _onSave(draft),
      ),
    );
  }

  List<Widget> _buildPayoutDays(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final isWeekly = _type == BillingCycleType.weekly;
    final isOtherDay =
        !_quickDays.contains(_monthDay) &&
        _monthDay != BillingCycle.lastDayAnchor;

    return [
      Text(
        l10n.billingCyclePayoutDayGroup.toUpperCase(),
        style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
      ),
      KaziSpacings.verticalXs,
      Wrap(
        spacing: KaziInsets.sm,
        runSpacing: KaziInsets.sm,
        children: isWeekly
            ? [
                for (
                  var weekday = DateTime.monday;
                  weekday <= DateTime.sunday;
                  weekday++
                )
                  KaziChip(
                    label: DateFormat.E(
                      Localizations.localeOf(context).toString(),
                    ).format(DateTime(2024, 1, weekday)),
                    isSelected: _weekday == weekday,
                    onTap: () => setState(() => _weekday = weekday),
                  ),
              ]
            : [
                for (final day in _quickDays)
                  KaziChip(
                    label: '$day',
                    isSelected: _monthDay == day,
                    onTap: () => setState(() => _monthDay = day),
                  ),
                KaziChip(
                  label: l10n.billingCycleLastDay,
                  isSelected: _monthDay == BillingCycle.lastDayAnchor,
                  onTap: () =>
                      setState(() => _monthDay = BillingCycle.lastDayAnchor),
                ),
                KaziChip(
                  label: isOtherDay
                      ? '${l10n.billingCycleOther} · $_monthDay'
                      : l10n.billingCycleOther,
                  isSelected: isOtherDay,
                  onTap: () => _pickOtherDay(context),
                ),
              ],
      ),
    ];
  }

  List<Widget> _buildCustomFields(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final today = _today;
    final yearAgo = DateTime(today.year - 1, today.month, today.day);
    final yearAhead = DateTime(today.year + 1, today.month, today.day);

    return [
      KaziFieldInput(
        label: l10n.billingCycleIntervalDays,
        controller: _intervalController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        validator: (_) => _intervalDays == null
            ? l10n.billingCycleIntervalError(
                CustomCycle.minIntervalDays,
                CustomCycle.maxIntervalDays,
              )
            : null,
        onChanged: (_) => setState(() {}),
      ),
      KaziSpacings.verticalSm,
      KaziFieldDate(
        label: l10n.billingCycleCustomAnchorDate,
        value: _anchorDate,
        // Widened to the stored anchor, or the calendar asserts on opening.
        firstDate: _anchorDate.isBefore(yearAgo) ? _anchorDate : yearAgo,
        lastDate: _anchorDate.isAfter(yearAhead) ? _anchorDate : yearAhead,
        onChanged: (date) => setState(() => _anchorDate = date),
      ),
      KaziSpacings.verticalXs,
      Text(
        l10n.billingCycleCustomAnchorHint,
        style: KaziTextStyles.bodySmall.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    ];
  }

  /// "Ciclo atual: 06/ago – 05/set. Fecha em 22 dias."
  ///
  /// The single most important element on this page: it is what makes "the day
  /// I am paid" legible as a window that *ends* on that day. Without it people
  /// set 1 when they mean 5.
  String _preview(BuildContext context, BillingCycle draft) {
    final locale = Localizations.localeOf(context).toString();
    final now = ref.read(timeServiceProvider).now;
    final range = draft.currentCycle(now);
    final format = DateFormat.MMMMd(locale);
    final l10n = KaziLocalizations.current;

    final rangeText = l10n.billingCyclePreview(
      l10n.billingCycleRange(
        format.format(range.start),
        format.format(range.end),
      ),
    );
    final closesText = l10n.billingCycleClosesInDays(draft.daysUntilClose(now));
    return '$rangeText.\n$closesText.';
  }

  Future<void> _onSave(BillingCycle draft) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(billingCycleControllerProvider.notifier).select(draft);
      if (mounted) KaziNavigator.pop();
    } on AppError catch (exception) {
      if (mounted) KaziSnackbar.show(context, exception.message);
    } catch (_) {
      if (mounted) {
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _frequencyLabel(BillingCycleType type) {
    final days = switch (type) {
      BillingCycleType.monthly => 30,
      BillingCycleType.fortnightly => 15,
      BillingCycleType.weekly => 7,
      BillingCycleType.custom => _intervalDays,
    };
    return days == null
        ? null
        : KaziLocalizations.current.billingCycleFrequency(days);
  }

  Future<void> _pickOtherDay(BuildContext context) async {
    final l10n = KaziLocalizations.current;
    final selected = await showKaziDropdownPicker(
      context: context,
      title: l10n.billingCyclePayday,
      searchLabel: l10n.search,
      noResultsLabel: l10n.noResults,
      selectedItem: DropdownItem(value: '$_monthDay', label: '$_monthDay'),
      items: [
        for (var day = 1; day <= 31; day++)
          DropdownItem(value: '$day', label: '$day'),
      ],
    );
    if (selected == null) return;
    setState(() => _monthDay = int.parse(selected.value));
  }
}
