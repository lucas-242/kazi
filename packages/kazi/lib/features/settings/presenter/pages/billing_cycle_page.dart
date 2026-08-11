import 'package:flutter/material.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

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
      WeeklyCycle() => 31,
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

  /// "Ciclo atual: 06/ago – 05/set".
  ///
  /// The single most important element on this page: it is what makes "the day
  /// I am paid" legible as a window that *ends* on that day. Without it people
  /// set 1 when they mean 5.
  String _preview(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final range = _draft.currentCycle(ref.read(timeServiceProvider).now);
    final format = DateFormat.MMMd(locale);

    return KaziLocalizations.current.billingCyclePreview(
      '${format.format(range.start)} – ${format.format(range.end)}',
    );
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

  String _typeLabel(BillingCycleType type) => switch (type) {
    BillingCycleType.monthly => KaziLocalizations.current.billingCycleMonthly,
    BillingCycleType.fortnightly =>
      KaziLocalizations.current.billingCycleFortnightly,
    BillingCycleType.weekly => KaziLocalizations.current.billingCycleWeekly,
  };

  String _weekdayLabel(int weekday) {
    final locale = Localizations.localeOf(context).toString();
    // Any Monday: adding weekday - 1 walks to the wanted day of that week.
    final reference = DateTime(2024, 1, weekday);
    return DateFormat.EEEE(locale).format(reference);
  }

  @override
  Widget build(BuildContext context) {
    final isWeekly = _type == BillingCycleType.weekly;

    return Scaffold(
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KaziPageTitle(title: KaziLocalizations.current.billingCycle),
            Text(
              KaziLocalizations.current.billingCycleDescription,
              style: KaziTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                height: 24 / 15,
                color: context.colors.textMuted,
              ),
            ),
            KaziSpacings.verticalLg,
            Wrap(
              spacing: KaziInsets.xs,
              runSpacing: KaziInsets.xs,
              children: [
                for (final type in BillingCycleType.values)
                  KaziChip(
                    label: _typeLabel(type),
                    isSelected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
              ],
            ),
            KaziSpacings.verticalLg,
            KaziDropdown(
              label: isWeekly
                  ? KaziLocalizations.current.billingCyclePaydayWeekday
                  : KaziLocalizations.current.billingCyclePayday,
              hint: isWeekly
                  ? KaziLocalizations.current.billingCyclePaydayWeekday
                  : KaziLocalizations.current.billingCyclePayday,
              searchLabel: KaziLocalizations.current.search,
              noResultsLabel: KaziLocalizations.current.noResults,
              selectedItem: DropdownItem(
                value: isWeekly ? '$_weekday' : '$_monthDay',
                label: isWeekly ? _weekdayLabel(_weekday) : '$_monthDay',
              ),
              items: [
                if (isWeekly)
                  for (
                    var weekday = DateTime.monday;
                    weekday <= DateTime.sunday;
                    weekday++
                  )
                    DropdownItem(
                      value: '$weekday',
                      label: _weekdayLabel(weekday),
                    )
                else
                  for (var day = 1; day <= 31; day++)
                    DropdownItem(value: '$day', label: '$day'),
              ],
              onChanged: (item) {
                if (item == null) return;
                setState(() {
                  if (isWeekly) {
                    _weekday = int.parse(item.value);
                  } else {
                    _monthDay = int.parse(item.value);
                  }
                });
              },
            ),
            KaziSpacings.verticalLg,
            Text(_preview(context), style: KaziTextStyles.titleSmall),
            KaziSpacings.verticalXLg,
            KaziElevatedButton.label(
              onTap: _isSaving ? null : _onSave,
              label: KaziLocalizations.current.save,
            ),
          ],
        ),
      ),
    );
  }
}
