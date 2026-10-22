import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/core/currency/currency_providers.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi/injector.dart';
import 'package:kazi/core/widgets/detail_info_row.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_status.dart';
import 'package:kazi/features/services/presenter/controllers/live_service_provider.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_status_controller.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

/// One service, read from the top down: what the user earns, then the facts
/// that produced it. See README.md.
class ServiceDetailsPage extends ConsumerWidget {
  const ServiceDetailsPage({super.key, required this.service});

  /// The service as it was when this page was pushed. Immutable, and handed
  /// over through go_router's `extra` — so it is a starting point, not the
  /// source of truth; see [liveServiceProvider].
  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Follows whichever list holds this service, so marking it as received
    // below repaints the page. Falls back to the pushed copy when no list has
    // it — reachable from a deep link.
    final service =
        ref.watch(liveServiceProvider(this.service.id)) ?? this.service;

    final defaultCurrency = ref.watch(kaziDefaultCurrencyProvider);
    final serviceCurrency = service.currencyOr(defaultCurrency);
    final rateBook = ref
        .watch(dayRateBookProvider(service.effectiveRateDate))
        .asData
        ?.value;

    Future<void> onDelete(Service service) async {
      KaziNavigator.pop();
      final controller = ref.read(serviceLandingControllerProvider.notifier);
      final dashboard = ref.read(dashboardControllerProvider.notifier);
      final agenda = ref.read(agendaControllerProvider.notifier);
      await controller.deleteService(service).then((_) {
        // The home and the agenda list it too, and would keep showing it.
        unawaited(dashboard.onRefresh());
        unawaited(agenda.onChangeServices());
        if (context.mounted) KaziNavigator.navigate(AppPage.services);
      });
    }

    Future<void> onSetCancelled({required bool cancelled}) async {
      final controller = ref.read(serviceStatusControllerProvider.notifier);
      try {
        await controller.setCancelled(service, cancelled: cancelled);
        if (!context.mounted) return;
        KaziUndoSnackbar.show(
          context,
          message: cancelled
              ? KaziLocalizations.current.serviceCancelled
              : KaziLocalizations.current.serviceReopened,
          // By id: the page may be gone by the time Undo is pressed, and the
          // copy it held would be the one from before the write either way.
          onUndo: () =>
              controller.setCancelledById(service.id, cancelled: !cancelled),
        );
      } on AppError catch (exception, trace) {
        reportShownError(
          ref.read,
          exception,
          trace,
          origin: 'ServiceDetailsPage',
        );
        if (context.mounted) KaziSnackbar.show(context, exception.message);
      } catch (exception, trace) {
        reportShownError(
          ref.read,
          exception,
          trace,
          origin: 'ServiceDetailsPage',
        );
        if (context.mounted) {
          KaziSnackbar.show(
            context,
            KaziLocalizations.current.errorUnknowError,
          );
        }
      }
    }

    void showWriteError(Object exception, StackTrace trace) {
      reportShownError(
        ref.read,
        exception,
        trace,
        origin: 'ServiceDetailsPage',
      );
      if (!context.mounted) return;
      KaziSnackbar.show(
        context,
        exception is AppError
            ? exception.message
            : KaziLocalizations.current.errorUnknowError,
      );
    }

    /// The pickers are bounded by what the repository accepts — from the start
    /// to now — and a moment outside them is explained rather than written.
    Future<void> onCorrectFinishedAt() async {
      final current = service.finishedAt;
      if (current == null) return;

      final now = ref.read(timeServiceProvider).now;
      final earliest = service.earliestFinish;
      final firstDay = DateTime(earliest.year, earliest.month, earliest.day);
      final initial = current.isAfter(now)
          ? now
          : current.isBefore(firstDay)
          ? firstDay
          : current;

      final day = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: firstDay,
        lastDate: now,
      );
      if (day == null || !context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null || !context.mounted) return;

      final at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
      if (at.isBefore(earliest) || at.isAfter(now)) {
        KaziSnackbar.show(
          context,
          at.isBefore(earliest)
              ? KaziLocalizations.current.finishedBeforeStart
              : KaziLocalizations.current.finishedInFuture,
        );
        return;
      }

      try {
        await ref
            .read(serviceStatusControllerProvider.notifier)
            .correctFinishedAt(service, at);
      } catch (exception, trace) {
        showWriteError(exception, trace);
      }
    }

    // Only cancelling asks: it takes the service out of every total the user
    // reads. Putting it back does not, and a dialog there would be ceremony.
    void onTapCancel() {
      showDialog<void>(
        context: context,
        builder: (context) => KaziDialog(
          title: KaziLocalizations.current.cancelServiceTitle(
            service.catalogItem?.name ?? KaziLocalizations.current.service,
          ),
          message: KaziLocalizations.current.cancelServiceImpact,
          confirmText: KaziLocalizations.current.cancelService,
          onCancel: KaziNavigator.pop,
          onConfirm: () {
            KaziNavigator.pop();
            unawaited(onSetCancelled(cancelled: true));
          },
        ),
      );
    }

    void onTapDelete() {
      showDialog<void>(
        context: context,
        builder: (context) => KaziDialog(
          title: KaziLocalizations.current.deleteForeverTitle(
            service.catalogItem?.name ?? KaziLocalizations.current.service,
          ),
          message: KaziLocalizations.current.deleteServiceImpact,
          confirmText: KaziLocalizations.current.deletePermanently,
          isDestructive: true,
          onCancel: KaziNavigator.pop,
          onConfirm: () => onDelete(service),
        ),
      );
    }

    return Scaffold(
      appBar: KaziAppBar(
        title: KaziLocalizations.current.service,
        actions: [
          KaziCircularButton.plain(
            onTap: () => KaziNavigator.push(
              AppPage.addServices,
              extra: ServiceArguments(service: service),
            ),
            semantics: KaziLocalizations.current.edit,
            child: const Icon(LucideIcons.pencil, size: 18),
          ),
          // Destructive and rare: it lives in the menu rather than competing
          // with the content for attention.
          KaziOverflowMenu(
            semantics: KaziLocalizations.current.actions,
            actions: [
              if (service.isCancelled)
                KaziOverflowAction(
                  label: KaziLocalizations.current.reopenService,
                  icon: Icons.restart_alt,
                  onTap: () => unawaited(onSetCancelled(cancelled: false)),
                )
              // A finished service cannot be cancelled; see services/README.md.
              else if (service.canBeCancelled)
                KaziOverflowAction(
                  label: KaziLocalizations.current.cancelService,
                  icon: Icons.block,
                  onTap: onTapCancel,
                ),
              KaziOverflowAction(
                label: KaziLocalizations.current.delete,
                icon: LucideIcons.trash2,
                isDestructive: true,
                onTap: onTapDelete,
              ),
            ],
          ),
          KaziSpacings.horizontalXs,
        ],
      ),
      body: KaziSafeArea(
        child: _ServiceDetails(
          service: service,
          currency: serviceCurrency,
          defaultCurrency: defaultCurrency,
          rateBook: rateBook,
          onTapFinishedAt: onCorrectFinishedAt,
        ),
      ),
      // A cancelled service is owed nothing, so the screen has nothing to
      // offer at the foot: reopening it lives in the menu, with the cancel it
      // undoes. Nor can it be finished.
      bottomNavigationBar: service.isCancelled
          ? null
          : _ReceiptCta(
              service: service,
              secondary:
                  service.isFinished ||
                      service.canBeFinishedAt(
                        ref.watch(timeServiceProvider).now,
                      )
                  ? _FinishButton(service: service, onError: showWriteError)
                  : null,
            ),
    );
  }
}

/// The one action this screen exists to offer, at full width where the thumb
/// already is. It says what it will do, and a paid service offers the undo.
class _ReceiptCta extends ConsumerStatefulWidget {
  const _ReceiptCta({required this.service, this.secondary});

  final Service service;

  /// Drawn above the receipt button, in the same bar.
  final Widget? secondary;

  @override
  ConsumerState<_ReceiptCta> createState() => _ReceiptCtaState();
}

class _ReceiptCtaState extends ConsumerState<_ReceiptCta> {
  bool _isSaving = false;

  Future<void> _onTap() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(serviceStatusControllerProvider.notifier).setReceived([
        widget.service,
      ], received: !widget.service.isReceived);
    } on AppError catch (exception, trace) {
      reportShownError(
        ref.read,
        exception,
        trace,
        origin: 'ServiceDetailsPage',
      );
      if (mounted) KaziSnackbar.show(context, exception.message);
    } catch (exception, trace) {
      reportShownError(
        ref.read,
        exception,
        trace,
        origin: 'ServiceDetailsPage',
      );
      if (mounted) {
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceived = widget.service.isReceived;

    return KaziFormFooter(
      label: isReceived
          ? KaziLocalizations.current.unmarkAsReceived
          : KaziLocalizations.current.markAsReceived,
      isOutlined: isReceived,
      // Ignored while the write is in flight: a second tap would toggle the
      // stamp back.
      onTap: _isSaving ? null : _onTap,
      secondary: widget.secondary,
      child: (button) => HintAnchor(
        hint: OnboardingHint.markReceived,
        // Nothing to explain about marking a service received when it already
        // is.
        enabled: !isReceived,
        radius: KaziRadii.sm,
        child: button,
      ),
    );
  }
}

/// The secondary action at the foot: marks the work done, or puts it back on
/// the agenda. Either way the undo hands back the exact stamp it replaced.
class _FinishButton extends ConsumerStatefulWidget {
  const _FinishButton({required this.service, required this.onError});

  final Service service;
  final void Function(Object exception, StackTrace trace) onError;

  @override
  ConsumerState<_FinishButton> createState() => _FinishButtonState();
}

class _FinishButtonState extends ConsumerState<_FinishButton> {
  bool _isSaving = false;

  Future<void> _onTap() async {
    final controller = ref.read(serviceStatusControllerProvider.notifier);
    final service = widget.service;
    final finishing = !service.isFinished;
    final previous = service.finishedAt;

    setState(() => _isSaving = true);
    try {
      await controller.setFinished(service, finished: finishing);
      if (!mounted) return;
      KaziUndoSnackbar.show(
        context,
        message: finishing
            ? KaziLocalizations.current.serviceMarkedFinished
            : KaziLocalizations.current.serviceBackOnAgenda,
        // By id: the page may be gone by the time Undo is pressed.
        onUndo: () => controller.setFinishedAtById(service.id, previous),
      );
    } catch (exception, trace) {
      widget.onError(exception, trace);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KaziElevatedButton.outlined(
      // Ignored while the write is in flight: a second tap would toggle back.
      onTap: _isSaving ? null : _onTap,
      label: widget.service.isFinished
          ? KaziLocalizations.current.unmarkAsFinished
          : KaziLocalizations.current.markAsFinished,
    );
  }
}

class _ServiceDetails extends StatelessWidget {
  const _ServiceDetails({
    required this.service,
    required this.currency,
    required this.defaultCurrency,
    required this.rateBook,
    required this.onTapFinishedAt,
  });

  final Service service;
  final SupportedCurrency currency;
  final SupportedCurrency defaultCurrency;
  final RateBook? rateBook;
  final VoidCallback onTapFinishedAt;

  /// The same amount restated in the user's default currency, or null when the
  /// service is already in it and there is nothing to restate.
  ///
  /// Null is also what a missing rate yields; it never falls back to the raw
  /// amount, which would label a foreign figure with the default currency.
  String? _inDefaultCurrency(double amount) {
    final book = rateBook;
    if (currency == defaultCurrency || book == null) return null;

    final converted = service.convert(
      amount,
      to: defaultCurrency,
      fallback: defaultCurrency,
      rateBook: book,
    );

    return converted == null
        ? null
        : '≈ ${NumberFormatUtils.formatCurrencyIn(converted, defaultCurrency)}';
  }

  /// "09/08/2026 · 14:00" — the time only when the service carries one. A
  /// service registered for a date alone sits at midnight, and printing
  /// "00:00" would invent a precision the record does not have.
  String get _date {
    final date = DateFormat.yMd().format(service.date).normalizeDate();
    final hasTime = service.date.hour != 0 || service.date.minute != 0;

    return hasTime ? '$date · ${DateFormat.Hm().format(service.date)}' : date;
  }

  /// "14:00 – 15:30 · 1 hour 30 min"; the end's day too when it is another
  /// day, and the start alone when no length is known.
  String? get _schedule {
    final start = service.startsAt;
    if (start == null) return null;

    final time = DateFormat.Hm();
    final end = service.endsAt;
    final duration = service.duration;
    if (end == null || duration == null) return time.format(start);

    final endLabel = service.isMultiDay
        ? '${DateFormat.yMd().format(end).normalizeDate()} ${time.format(end)}'
        : time.format(end);
    return '${time.format(start)} – $endLabel · '
        '${DurationFormatUtils.short(duration)}';
  }

  String get _finishedAt {
    final finishedAt = service.finishedAt!;
    return '${DateFormat.yMd().format(finishedAt).normalizeDate()} · '
        '${DateFormat.Hm().format(finishedAt)}';
  }

  String get _status => switch (service.status) {
    ServiceStatus.pending => KaziLocalizations.current.statusPending,
    ServiceStatus.received => KaziLocalizations.current.receivedOn(
      DateFormat.yMd().format(service.receivedAt!).normalizeDate(),
    ),
    ServiceStatus.cancelled => KaziLocalizations.current.cancelledOn(
      DateFormat.yMd().format(service.cancelledAt!).normalizeDate(),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final clientName = service.clientName ?? '';
    final description = service.description ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EarningsPanel(
          service: service,
          currency: currency,
          converted: _inDefaultCurrency(service.commissionValue),
        ),
        KaziSpacings.verticalSm,
        DetailInfoRow(
          label: KaziLocalizations.current.serviceType,
          value: service.catalogItem?.name ?? '',
          categoryColor: service.catalogItem?.colorAs,
        ),
        if (clientName.isNotEmpty)
          DetailInfoRow(
            label: KaziLocalizations.current.client,
            value: clientName,
          ),
        DetailInfoRow(label: KaziLocalizations.current.date, value: _date),
        if (_schedule case final String schedule)
          DetailInfoRow(
            label: KaziLocalizations.current.schedule,
            value: schedule,
          ),
        DetailInfoRow(
          label: KaziLocalizations.current.situation,
          value: _status,
        ),
        // Tappable: the stamp may need correcting, and this is where it shows.
        if (service.isFinished)
          DetailInfoRow(
            label: KaziLocalizations.current.finishedAtLabel,
            value: _finishedAt,
            onTap: onTapFinishedAt,
          ),
        if (description.isNotEmpty)
          DetailInfoRow(
            label: KaziLocalizations.current.observation,
            value: description,
          ),
        KaziSpacings.verticalSm,
      ],
    );
  }
}

/// What the user keeps, first and largest — the answer to the question that
/// opened this screen. The gross is context, and follows.
class _EarningsPanel extends StatelessWidget {
  const _EarningsPanel({
    required this.service,
    required this.currency,
    required this.converted,
  });

  final Service service;
  final SupportedCurrency currency;
  final String? converted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.money.surface,
        borderRadius: KaziRadii.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // Upper-cased at the call site: Flutter has no text-transform.
            KaziLocalizations.current.yourEarnings.toUpperCase(),
            style: KaziTextStyles.tag.copyWith(color: colors.money.label),
          ),
          KaziSpacings.verticalXs,
          // Scaled rather than wrapped: a truncated amount is worse than a
          // smaller one.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormatUtils.formatCurrencyIn(
                service.commissionValue,
                currency,
              ),
              style: KaziTextStyles.amount.copyWith(
                color: colors.money.onSurface,
              ),
            ),
          ),
          if (converted case final String amount) ...[
            KaziSpacings.verticalXxs,
            Text(
              amount,
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.money.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          KaziSpacings.verticalXxs,
          Text(
            // Reads `effectiveCommissionPercent`, so a service registered
            // before commissions existed shows the 100% it was paid at rather
            // than a blank.
            KaziLocalizations.current.commissionOfGross(
              NumberFormatUtils.formatPercent(
                service.effectiveCommissionPercent,
              ),
              NumberFormatUtils.formatCurrencyIn(service.value, currency),
            ),
            style: KaziTextStyles.labelSmall.copyWith(
              color: colors.money.accent,
            ),
          ),
        ],
      ),
    );
  }
}
