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
    final convertedBalance = rateBook == null
        ? null
        : service.convert(
            service.commissionValue,
            to: defaultCurrency,
            fallback: defaultCurrency,
            rateBook: rateBook,
          );
    // Only offered when there is a real rate to show it with; an unconverted
    // amount labelled with the default currency would be a lie.
    final showConversion =
        serviceCurrency != defaultCurrency && convertedBalance != null;

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
            child: KaziCircularButton(
              onTap: onToggleReceived,
              backgroundColor: service.isReceived
                  ? context.colors.success.surface
                  : context.colors.brand.fill,
              child: Icon(
                service.isReceived
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: service.isReceived
                    ? context.colors.success.onSurface
                    : context.colors.brand.onFill,
              ),
            ),
          ),
          KaziSpacings.horizontalXs,
          KaziCircularButton(
            onTap: () => KaziNavigator.push(
              AppPage.addServices,
              extra: ServiceArguments(service: service),
            ),
            backgroundColor: context.colors.brand.fill,
            child: Icon(Icons.edit, color: context.colors.brand.onFill),
          ),
          KaziSpacings.horizontalXs,
          KaziCircularButton(
            onTap: onTapDelete,
            backgroundColor: context.colors.brand.fill,
            child: Icon(
              Icons.delete,
              color: context.colors.brand.onFill,
            ),
          ),
          KaziSpacings.horizontalSm,
        ],
      ),
      body: KaziSafeArea(
        child: Column(
          children: [
            KaziSpacings.verticalLg,
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KaziInsets.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${service.type?.name}',
                      style: KaziTextStyles.titleMedium,
                    ),
                    KaziSpacings.verticalXs,
                    Text(
                      DateFormat.yMd().format(service.date).normalizeDate(),
                      style: KaziTextStyles.labelMedium,
                    ),
                    if (service.clientName != null &&
                        service.clientName!.isNotEmpty)
                      _ClientNameRow(name: service.clientName!),
                    if (service.receivedAt case final DateTime at)
                      _ReceivedRow(receivedAt: at),
                    KaziSpacings.verticalXLg,
                    _RowText(
                      leftText: KaziLocalizations.current.myBalance,
                      rightText: NumberFormatUtils.formatCurrencyIn(
                        service.commissionValue,
                        serviceCurrency,
                      ),
                      rightTextStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(
                            color: context.colors.success.onSurface,
                          ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                      child: Divider(),
                    ),
                    _RowText(
                      leftText: KaziLocalizations.current.discount,
                      rightText: NumberFormatUtils.formatCurrencyIn(
                        service.withheldValue,
                        serviceCurrency,
                      ),
                      rightTextStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(
                            color: context.colors.warning.onSurface,
                          ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                      child: Divider(),
                    ),
                    _RowText(
                      leftText: KaziLocalizations.current.grossValue,
                      rightText: NumberFormatUtils.formatCurrencyIn(
                        service.value,
                        serviceCurrency,
                      ),
                    ),
                    if (showConversion) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                        child: Divider(),
                      ),
                      _RowText(
                        leftText:
                            '${KaziLocalizations.current.myBalance} (${defaultCurrency.isoCode})',
                        rightText:
                            '≈ ${NumberFormatUtils.formatCurrencyIn(convertedBalance, defaultCurrency)}',
                        rightTextStyle: Theme.of(context).textTheme.titleSmall!
                            .copyWith(
                              color: context.colors.textMuted,
                            ),
                      ),
                    ],
                    service.description != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: KaziInsets.lg,
                                ),
                                child: Divider(),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    KaziLocalizations.current.description,
                                    style: KaziTextStyles.titleSmall,
                                  ),
                                  KaziSpacings.verticalXs,
                                  Text(
                                    service.description!,
                                    style: KaziTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              KaziSpacings.verticalXs,
                            ],
                          )
                        : KaziSpacings.verticalXs,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          // runs past the edge of the card on a phone.
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

class _RowText extends StatelessWidget {
  const _RowText({
    required this.leftText,
    required this.rightText,
    this.rightTextStyle,
  });
  final String leftText;
  final String rightText;
  final TextStyle? rightTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(leftText, style: KaziTextStyles.titleSmall),
        Text(rightText, style: rightTextStyle ?? KaziTextStyles.titleSmall),
      ],
    );
  }
}
