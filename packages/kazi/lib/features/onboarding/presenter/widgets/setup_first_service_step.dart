import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_item_sheet.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Screen 5 — one service the user has actually done, so the app leaves the
/// zero before the home ever opens.
///
/// The date is offered, with today preselected, and never forced. Forcing
/// "today" would invent a record in the first minute of use, and a false number
/// is worse than an empty list in an app whose whole pitch is trust in the
/// number.
class SetupFirstServiceStep extends ConsumerStatefulWidget {
  const SetupFirstServiceStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  ConsumerState<SetupFirstServiceStep> createState() =>
      _SetupFirstServiceStepState();
}

class _SetupFirstServiceStepState
    extends ConsumerState<SetupFirstServiceStep> {
  GuidedSetupController get _controller =>
      ref.read(guidedSetupControllerProvider.notifier);

  DateTime get _today {
    final now = ref.read(timeServiceProvider).now;
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _selectedDate => widget.state.firstServiceDate ?? _today;

  bool get _isToday => _selectedDate == _today;

  bool get _isYesterday =>
      _selectedDate ==
      DateTime(_today.year, _today.month, _today.day - 1);

  Future<void> _pickOtherDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_today.year - 2),
      lastDate: _today,
    );
    if (picked != null) _controller.chooseFirstServiceDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final state = widget.state;
    final colors = context.colors;

    // Only priced services can be registered here — an unpriced one would need
    // an amount, and this screen is meant to cost ten seconds.
    final choices = state.selectedItems
        .where((item) => (item.value ?? 0) > 0)
        .toList();
    final chosen = state.firstServiceItemId;
    final isSaving = state.status == BaseStateStatus.loading;

    return SetupScaffold(
      step: SetupStep.firstService,
      onClose: () => showSetupExitDialog(context, ref),
      backgroundColor: colors.money.surface,
      foregroundColor: colors.money.onSurface,
      title: l10n.setupFirstServiceTitle,
      subtitle: l10n.setupFirstServiceSubtitle,
      action: KaziElevatedButton.label(
        label: l10n.setupFirstServiceRegister,
        onTap: chosen == null || isSaving
            ? null
            : () => _controller.complete(registerService: true),
      ),
      // Hidden while saving rather than disabled: a second tap would start a
      // second write of the same catalog.
      footer: isSaving
          ? null
          : KaziTextButton(
              onTap: () => _controller.complete(registerService: false),
              child: Text(l10n.setupFirstServiceSkip),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in choices)
            OptionTile(
              label: item.name,
              selected: chosen == item.id,
              detail: NumberFormatUtils.formatCurrencyIn(
                item.value!,
                state.currency,
              ),
              onTap: () => _controller.chooseFirstService(item.id),
            ),
          KaziSpacings.verticalMd,
          Text(l10n.setupFirstServiceWhen, style: KaziTextStyles.titleSmall),
          KaziSpacings.verticalXs,
          Wrap(
            spacing: KaziInsets.xs,
            runSpacing: KaziInsets.xs,
            children: [
              // Three chips rather than a calendar: people install an earnings
              // app after hours or on a day off, so today and yesterday cover
              // almost everything with one tap.
              KaziChip(
                label: l10n.today,
                isSelected: _isToday,
                onTap: () => _controller.chooseFirstServiceDate(_today),
              ),
              KaziChip(
                label: l10n.yesterday,
                isSelected: _isYesterday,
                onTap: () => _controller.chooseFirstServiceDate(
                  DateTime(_today.year, _today.month, _today.day - 1),
                ),
              ),
              KaziChip(
                label: l10n.setupFirstServiceOtherDay,
                isSelected: !_isToday && !_isYesterday,
                onTap: _pickOtherDay,
              ),
            ],
          ),
          if (!widget.state.billingCycle
              .currentCycle(_today)
              .contains(_selectedDate)) ...[
            KaziSpacings.verticalXs,
            Text(
              l10n.setupFirstServicePastCycle,
              style: KaziTextStyles.bodySmall.copyWith(
                color: colors.money.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
