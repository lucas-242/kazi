import 'package:flutter/material.dart';
import 'package:kazi/core/currency/currency_providers.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/onboarding/domain/models/onboarding_hint.dart';
import 'package:kazi/features/onboarding/presenter/widgets/hint_anchor.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/live_service_provider.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_receipt_controller.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

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
      await controller.deleteService(service).then((_) {
        if (context.mounted) KaziNavigator.navigate(AppPage.services);
      });
    }

    void onTapDelete() {
      showDialog(
        context: context,
        builder: (context) => KaziDialog(
          title: KaziLocalizations.current.delete,
          message: KaziLocalizations.current.wouldYouLikeDelete(
            KaziLocalizations.current.thisService,
          ),
          confirmText: KaziLocalizations.current.delete,
          isDestructive: true,
          onCancel: KaziNavigator.pop,
          onConfirm: () => onDelete(service),
        ),
      );
    }

    Future<void> onToggleReceived() async {
      try {
        await ref.read(serviceReceiptControllerProvider.notifier).setReceived([
          service,
        ], received: !service.isReceived);
      } on AppError catch (exception) {
        if (context.mounted) KaziSnackbar.show(context, exception.message);
      } catch (_) {
        if (context.mounted) {
          KaziSnackbar.show(
            context,
            KaziLocalizations.current.errorUnknowError,
          );
        }
      }
    }

    return Scaffold(
      appBar: KaziAppBar(
        title: KaziLocalizations.current.details,
        actions: [
          HintAnchor(
            hint: OnboardingHint.markReceived,
            // Nothing to explain about marking a service received when it
            // already is.
            enabled: !service.isReceived,
            child: KaziCircularButton.plain(
              onTap: onToggleReceived,
              foregroundColor: service.isReceived
                  ? context.colors.success.onSurface
                  : null,
              child: Icon(
                service.isReceived
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
              ),
            ),
          ),
          KaziCircularButton.plain(
            onTap: () => KaziNavigator.push(
              AppPage.addServices,
              extra: ServiceArguments(service: service),
            ),
            child: const Icon(Icons.edit),
          ),
          KaziCircularButton.plain(
            onTap: onTapDelete,
            child: const Icon(Icons.delete),
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
        ),
      ),
    );
  }
}

class _ServiceDetails extends StatelessWidget {
  const _ServiceDetails({
    required this.service,
    required this.currency,
    required this.defaultCurrency,
    required this.rateBook,
  });

  final Service service;
  final SupportedCurrency currency;
  final SupportedCurrency defaultCurrency;
  final RateBook? rateBook;

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clientName = service.clientName ?? '';
    final description = service.description ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KaziColorDot(color: service.catalogItem?.colorAs, size: 18),
            KaziSpacings.horizontalSm,
            Expanded(
              child: Text(
                service.catalogItem?.name ?? '',
                style: KaziTextStyles.titleMedium,
              ),
            ),
          ],
        ),
        KaziSpacings.verticalXs,
        Text(
          DateFormat.yMd().format(service.date).normalizeDate(),
          style: KaziTextStyles.labelMedium,
        ),
        if (clientName.isNotEmpty) _ClientNameRow(name: clientName),
        if (service.receivedAt case final DateTime at)
          _ReceivedRow(receivedAt: at),
        KaziSpacings.verticalXLg,
        _InfoRow(
          label: KaziLocalizations.current.commissionValue,
          value: NumberFormatUtils.formatCurrencyIn(
            service.commissionValue,
            currency,
          ),
          // The rate beside the amount it produced. Reads
          // `effectiveCommissionPercent`, so a service registered before
          // commissions existed shows the 100% it was paid at rather than a
          // blank.
          qualifier: NumberFormatUtils.formatPercent(
            service.effectiveCommissionPercent,
          ),
          secondary: _inDefaultCurrency(service.commissionValue),
          valueColor: colors.success.onSurface,
        ),
        KaziSpacings.verticalMd,
        _InfoRow(
          label: KaziLocalizations.current.withheld,
          value: NumberFormatUtils.formatCurrencyIn(
            service.withheldValue,
            currency,
          ),
          secondary: _inDefaultCurrency(service.withheldValue),
          valueColor: colors.warning.onSurface,
        ),
        KaziSpacings.verticalMd,
        _InfoRow(
          label: KaziLocalizations.current.serviceValue,
          value: NumberFormatUtils.formatCurrencyIn(service.value, currency),
          secondary: _inDefaultCurrency(service.value),
        ),
        if (description.isNotEmpty) ...[
          KaziSpacings.verticalMd,
          _InfoRow(
            label: KaziLocalizations.current.description,
            value: description,
          ),
        ],
      ],
    );
  }
}

class _ClientNameRow extends StatelessWidget {
  const _ClientNameRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.sm),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            size: 18,
            color: context.colors.textMuted,
          ),
          KaziSpacings.horizontalXs,
          Text(
            '${KaziLocalizations.current.client}: $name',
            style: KaziTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }
}

/// "Recebido em 05/09" — shown only once the service has actually been paid.
class _ReceivedRow extends StatelessWidget {
  const _ReceivedRow({required this.receivedAt});

  final DateTime receivedAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.sm),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: context.colors.success.onSurface,
          ),
          KaziSpacings.horizontalXs,
          // Flexible: "received on <date>" is a translated sentence, and it
          // runs past the edge of the screen on a phone.
          Flexible(
            child: Text(
              KaziLocalizations.current.receivedOn(
                DateFormat.yMd().format(receivedAt).normalizeDate(),
              ),
              style: KaziTextStyles.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.qualifier,
    this.secondary,
    this.valueColor,
  });

  final String label;
  final String value;

  /// Sits beside [value], muted — what qualifies the amount rather than
  /// restates it.
  final String? qualifier;

  /// The same amount in the user's default currency, under the one the service
  /// was actually registered in.
  final String? secondary;

  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: KaziTextStyles.bodySmall.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        KaziSpacings.verticalXs,
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: KaziInsets.xs,
          children: [
            Text(
              value,
              style: KaziTextStyles.bodyMedium.copyWith(color: valueColor),
            ),
            if (qualifier case final String rate)
              Text(
                '($rate)',
                style: KaziTextStyles.labelSmall.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
          ],
        ),
        if (secondary case final String converted) ...[
          KaziSpacings.verticalXxs,
          Text(
            converted,
            style: KaziTextStyles.labelSmall.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
