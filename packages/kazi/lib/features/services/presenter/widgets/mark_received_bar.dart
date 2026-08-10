import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service_totals.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_receipt_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Stamps everything currently listed and still owed as paid.
///
/// Lives here rather than on the home because this is the operational screen —
/// the home answers "how much am I getting", this answers "what did I do". And
/// it acts on **what is listed**, not on the billing cycle: this tab has a
/// window of its own, so a button promising "the cycle" would stamp services
/// the user cannot see. Hence the count in the label, which is always the
/// number of rows below it that will change.
class MarkReceivedBar extends ConsumerStatefulWidget {
  const MarkReceivedBar({super.key, required this.totals});

  final ServiceTotals totals;

  @override
  ConsumerState<MarkReceivedBar> createState() => _MarkReceivedBarState();
}

class _MarkReceivedBarState extends ConsumerState<MarkReceivedBar> {
  bool _isSaving = false;

  /// The pending share, in the totals' currency. Null when a rate is missing:
  /// an understated amount on a button that writes to every one of those
  /// services would be worse than no amount at all.
  String? get _pendingAmount {
    if (widget.totals.isPartial) return null;

    return NumberFormatUtils.formatCurrencyIn(
      widget.totals.commission - widget.totals.receivedCommission,
      widget.totals.currency,
    );
  }

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

  /// Undo carries the exact ids that were written, rather than re-deriving
  /// them from a list that may have moved on — one mistaken tap otherwise
  /// rewrites dozens of payment dates with no way back.
  void _showUndo(List<String> ids) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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

  void _onTap() {
    showDialog(
      context: context,
      builder: (dialogContext) => KaziDialog(
        title: KaziLocalizations.current.received,
        message: KaziLocalizations.current.markListedReceivedConfirm(
          widget.totals.pendingCount,
        ),
        confirmText: KaziLocalizations.current.confirm,
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
    final pending = widget.totals.pendingCount;
    // Nothing owed, nothing to offer.
    if (pending == 0) return const SizedBox.shrink();

    final amount = _pendingAmount;
    final label = amount == null
        ? KaziLocalizations.current.markListedReceived(pending)
        : '${KaziLocalizations.current.markListedReceived(pending)} · $amount';

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.sm),
      child: KaziElevatedButton.outlined(
        onTap: _isSaving ? null : _onTap,
        label: label,
      ),
    );
  }
}
