import 'package:flutter/material.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(billingCycleProvider);
    _type = current.type;
    _monthDay = switch (current) {
      MonthlyCycle(:final anchorDay) => anchorDay,
      FortnightlyCycle(:final anchorDay) => anchorDay,
      WeeklyCycle() => BillingCycle.lastDayAnchor,
    };
    _weekday = switch (current) {
      WeeklyCycle(:final anchorWeekday) => anchorWeekday,
      _ => DateTime.friday,
    };
  }

  BillingCycle get _draft => switch (_type) {
    BillingCycleType.monthly => MonthlyCycle(anchorDay: _monthDay),
    BillingCycleType.fortnightly => FortnightlyCycle(anchorDay: _monthDay),
    BillingCycleType.weekly => WeeklyCycle(anchorWeekday: _weekday),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final colors = context.colors;
    final isWeekly = _type == BillingCycleType.weekly;
    final isOtherDay =
        !isWeekly &&
        !_quickDays.contains(_monthDay) &&
        _monthDay != BillingCycle.lastDayAnchor;

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
                detail: l10n.billingCycleFrequency(_frequencyDays(type)),
                onTap: () => setState(() => _type = type),
              ),
            KaziSpacings.verticalMd,
            Text(
              l10n.billingCyclePayoutDayGroup.toUpperCase(),
              style: KaziTextStyles.tag.copyWith(color: colors.textMuted),
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
                        onTap: () => setState(
                          () => _monthDay = BillingCycle.lastDayAnchor,
                        ),
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
            KaziSpacings.verticalLg,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KaziInsets.sm),
              decoration: BoxDecoration(
                color: colors.success.surface,
                borderRadius: KaziRadii.smBorder,
                border: Border.all(color: colors.success.fill),
              ),
              child: Text(
                _preview(context),
                style: KaziTextStyles.labelSmall.copyWith(
                  color: colors.success.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: KaziFormFooter(
        label: l10n.billingCycleSave,
        onTap: _isSaving ? null : _onSave,
      ),
    );
  }

  /// "Ciclo atual: 06/ago – 05/set. Fecha em 22 dias."
  ///
  /// The single most important element on this page: it is what makes "the day
  /// I am paid" legible as a window that *ends* on that day. Without it people
  /// set 1 when they mean 5.
  String _preview(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final now = ref.read(timeServiceProvider).now;
    final range = _draft.currentCycle(now);
    final format = DateFormat.MMMMd(locale);
    final l10n = KaziLocalizations.current;

    final rangeText = l10n.billingCyclePreview(
      l10n.billingCycleRange(
        format.format(range.start),
        format.format(range.end),
      ),
    );
    final closesText = l10n.billingCycleClosesInDays(
      _draft.daysUntilClose(now),
    );
    return '$rangeText.\n$closesText.';
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(billingCycleControllerProvider.notifier).select(_draft);
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

  static int _frequencyDays(BillingCycleType type) => switch (type) {
    BillingCycleType.monthly => 30,
    BillingCycleType.fortnightly => 15,
    BillingCycleType.weekly => 7,
  };

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
