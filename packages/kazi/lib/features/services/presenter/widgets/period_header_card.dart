import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_receipt_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_period_l10n.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The header of the current cut: which period is on screen, what it earned,
/// and how much of it has not arrived. Fixed above the first row and identical
/// in both views, because both describe the same services. See README.md.
///
/// It obeys the filters — what it reports is always the exact sum of what is
/// below it — and its last line is the bulk action, which only exists while
/// something is owed.
class PeriodHeaderCard extends ConsumerWidget {
  const PeriodHeaderCard({super.key, required this.state, this.chart});

  final ServiceLandingState state;

  /// The summary's weekly bars, which belong inside the card rather than under
  /// it: they break down the same amount the card just reported.
  final Widget? chart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final totals = state.totals;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: KaziRadii.smBorder,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // Upper-cased at the call site: Flutter has no
                  // text-transform.
                  KaziLocalizations.current
                      .periodYourEarnings(state.periodLabel)
                      .toUpperCase(),
                  style: KaziTextStyles.tag.copyWith(color: colors.textMuted),
                ),
              ),
              KaziSpacings.horizontalXs,
              Text(
                KaziLocalizations.current.servicesCount(
                  state.visibleServices.length,
                ),
                style: KaziTextStyles.tag.copyWith(color: colors.textMuted),
              ),
            ],
          ),
          KaziSpacings.verticalXs,
          // Scaled rather than wrapped: a truncated amount is worse than a
          // smaller one.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormatUtils.formatCurrencyIn(
                totals.commission,
                totals.currency,
              ),
              style: KaziTextStyles.amount,
            ),
          ),
          KaziSpacings.verticalXs,
          Text(
            _subtitle(totals),
            style: KaziTextStyles.labelSmall.copyWith(color: colors.textMuted),
          ),
          if (chart case final Widget bars) ...[
            KaziSpacings.verticalMd,
            bars,
          ],
          if (totals.pendingCount > 0) _MarkPendingReceived(totals: totals),
        ],
      ),
    );
  }

  /// "de R$ 4.280 gerados · R$ 890 já recebidos · R$ 822 pendentes" — the three
  /// words, in the one order that makes the arithmetic readable.
  ///
  /// The split is dropped when nothing has been paid: a permanent "R$ 0 já
  /// recebidos" reads as a problem rather than as absence.
  String _subtitle(ServiceTotals totals) {
    final l10n = KaziLocalizations.current;
    String money(double amount) =>
        NumberFormatUtils.formatCurrencyIn(amount, totals.currency);

    final generated = l10n.generatedFromAmount(money(totals.value));
    if (!totals.hasReceived) return generated;

    return '$generated · '
        '${l10n.alreadyReceived(money(totals.receivedCommission))} · '
        '${l10n.pendingAmount(money(totals.pendingCommission))}';
  }
}

/// Stamps everything **currently listed** and still owed as paid — never the
/// billing cycle, which would stamp services the user cannot see. The count in
/// the label is always the number of rows below it.
class _MarkPendingReceived extends ConsumerStatefulWidget {
  const _MarkPendingReceived({required this.totals});

  final ServiceTotals totals;

  @override
  ConsumerState<_MarkPendingReceived> createState() =>
      _MarkPendingReceivedState();
}

class _MarkPendingReceivedState extends ConsumerState<_MarkPendingReceived> {
  bool _isSaving = false;

  ServiceTotals get _totals => widget.totals;

  /// The pending share, in the totals' currency. Null when a rate is missing —
  /// an understated amount here is worse than no amount at all.
  String? get _pendingAmount => _totals.isPartial
      ? null
      : NumberFormatUtils.formatCurrencyIn(
          _totals.pendingCommission,
          _totals.currency,
        );

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    try {
      final ids = await ref
          .read(serviceLandingControllerProvider.notifier)
          .markListedAsReceived();

      if (mounted && ids.isNotEmpty) _showUndo(ids);
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

  /// The exact ids that were written, never re-derived from a list that may
  /// have moved on: one mistaken tap would rewrite dozens of payment dates.
  void _showUndo(List<String> ids) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        persist: false,
        content: Text(KaziLocalizations.current.markedAsReceived),
        action: SnackBarAction(
          label: KaziLocalizations.current.undo,
          onPressed: () => ref
              .read(serviceReceiptControllerProvider.notifier)
              .setReceivedByIds(ids, received: false),
        ),
      ),
    );
  }

  /// Says what it is about to do, in money, and says what it will leave alone.
  /// The second half is the reassurance the doc asks for: a bulk stamp on a
  /// month's earnings is the one action nobody wants to guess about.
  String get _confirmMessage {
    final l10n = KaziLocalizations.current;
    final amount = _pendingAmount;
    final untouched = _totals.receivedCount;

    return [
      if (amount != null) l10n.markListedReceivedBody(amount),
      if (untouched > 0) l10n.markListedReceivedUntouched(untouched),
    ].join('\n\n');
  }

  void _onTap() {
    showDialog<void>(
      context: context,
      builder: (_) => KaziDialog(
        title: KaziLocalizations.current.markListedReceivedConfirm(
          _totals.pendingCount,
        ),
        message: _confirmMessage,
        confirmText: KaziLocalizations.current.markReceived,
        onCancel: KaziNavigator.pop,
        onConfirm: () {
          KaziNavigator.pop();
          _confirm();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amount = _pendingAmount;
    final label = KaziLocalizations.current.markListedReceived(
      _totals.pendingCount,
    );

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: KaziInsets.md, color: colors.border),
          InkWell(
            // Ignored while the write is in flight: a second tap would stamp
            // a list that is already being stamped.
            onTap: _isSaving ? null : _onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: KaziInsets.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.done_all,
                    size: KaziSizings.iconSm,
                    color: colors.brand.text,
                  ),
                  KaziSpacings.horizontalXs,
                  Expanded(
                    child: Text(
                      amount == null ? label : '$label · $amount',
                      style: KaziTextStyles.labelLarge.copyWith(
                        color: colors.brand.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
