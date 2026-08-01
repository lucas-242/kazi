import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart' hide Service;

class ServiceDetailsPage extends ConsumerWidget {
  const ServiceDetailsPage({super.key, required this.service});
  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultCurrency = ref.watch(kaziDefaultCurrencyProvider);
    final serviceCurrency = service.currencyOr(defaultCurrency);
    final showConversion = serviceCurrency != defaultCurrency;

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

    return Scaffold(
      appBar: KaziAppBar(
        title: KaziLocalizations.current.details,
        actions: [
          KaziCircularButton(
            onTap: () => KaziNavigator.push(
              AppPage.addServices,
              extra: ServiceArguments(service: service),
            ),
            backgroundColor: KaziColors.primary,
            child: Icon(Icons.edit, color: KaziColors.black),
          ),
          KaziSpacings.horizontalXs,
          KaziCircularButton(
            onTap: onTapDelete,
            backgroundColor: KaziColors.primary,
            child: Icon(Icons.delete, color: KaziColors.black),
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
                      style: KaziTextStyles.titleMd,
                    ),
                    KaziSpacings.verticalXs,
                    Text(
                      DateFormat.yMd().format(service.date).normalizeDate(),
                      style: KaziTextStyles.labelMd,
                    ),
                    if (service.clientName != null &&
                        service.clientName!.isNotEmpty)
                      _ClientNameRow(name: service.clientName!),
                    KaziSpacings.verticalXLg,
                    _RowText(
                      leftText: KaziLocalizations.current.myBalance,
                      rightText: NumberFormatUtils.formatCurrencyIn(
                        service.valueWithDiscount,
                        serviceCurrency,
                      ),
                      rightTextStyle: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(color: KaziColors.green),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                      child: Divider(),
                    ),
                    _RowText(
                      leftText: KaziLocalizations.current.discount,
                      rightText: NumberFormatUtils.formatCurrencyIn(
                        service.valueDiscounted,
                        serviceCurrency,
                      ),
                      rightTextStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(color: KaziColors.orange),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                      child: Divider(),
                    ),
                    _RowText(
                      leftText: KaziLocalizations.current.totalReceived,
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
                            '≈ ${NumberFormatUtils.formatCurrencyIn(service.convert(service.valueWithDiscount, to: defaultCurrency, fallback: defaultCurrency), defaultCurrency)}',
                        rightTextStyle: Theme.of(context).textTheme.titleSmall!
                            .copyWith(color: KaziColors.grey),
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
                                    style: KaziTextStyles.titleSm,
                                  ),
                                  KaziSpacings.verticalXs,
                                  Text(
                                    service.description!,
                                    style: KaziTextStyles.sm,
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
          Icon(Icons.person_outline, size: 18, color: KaziColors.grey),
          KaziSpacings.horizontalXs,
          Text(
            '${KaziLocalizations.current.client}: $name',
            style: KaziTextStyles.labelMd,
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
        Text(leftText, style: KaziTextStyles.titleSm),
        Text(rightText, style: rightTextStyle ?? KaziTextStyles.titleSm),
      ],
    );
  }
}
