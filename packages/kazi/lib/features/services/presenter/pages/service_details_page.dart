import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
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
      body: KaziSafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SubNavBar(
                title: KaziLocalizations.current.details,
                pills: [
                  KaziPillButton(
                    onTap: () => KaziNavigator.push(
                      AppPage.addServices,
                      extra: ServiceArguments(service: service),
                    ),
                    child: Text(KaziLocalizations.current.edit),
                  ),
                  KaziSpacings.horizontalXs,
                  KaziPillButton(
                    backgroundColor: context.colorsScheme.error,
                    onTap: onTapDelete,
                    child: Text(KaziLocalizations.current.delete),
                  ),
                ],
              ),
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
                      KaziSpacings.verticalXLg,
                      _RowText(
                        leftText: KaziLocalizations.current.myBalance,
                        rightText: NumberFormatUtils.formatCurrency(
                          context,
                          service.valueWithDiscount,
                        ),
                        rightTextStyle: Theme.of(context).textTheme.titleSmall!
                            .copyWith(color: KaziColors.green),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                        child: Divider(),
                      ),
                      _RowText(
                        leftText: KaziLocalizations.current.discount,
                        rightText: NumberFormatUtils.formatCurrency(
                          context,
                          service.valueDiscounted,
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
                        rightText: NumberFormatUtils.formatCurrency(
                          context,
                          service.value,
                        ),
                      ),
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
