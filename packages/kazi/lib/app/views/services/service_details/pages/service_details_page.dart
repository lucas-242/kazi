import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kazi/app/models/service.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/widgets/buttons/buttons.dart';
import 'package:kazi/app/shared/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:kazi/app/shared/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:kazi/app/shared/widgets/texts/row_text/row_text.dart';
import 'package:kazi/app/views/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:kazi_core/kazi_core.dart' hide Service;

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key, required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    Future<void> onDelete(Service service) async {
      context.back();
      final cubit = context.read<ServiceLandingCubit>();
      await cubit.deleteService(service).then((_) {
        if (context.mounted) context.navigateTo(AppPage.services);
      });
    }

    void onTapDelete() {
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          message: KaziLocalizations.current.wouldYouLikeDelete(
            KaziLocalizations.current.thisService,
          ),
          confirmText: KaziLocalizations.current.delete,
          onCancel: () => context.back(),
          onConfirm: () => onDelete(service),
        ),
      );
    }

    return CustomSafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            BackAndPills(
              text: KaziLocalizations.current.details,
              pills: [
                PillButton(
                  onTap: () =>
                      context.navigateTo(AppPage.addServices, service: service),
                  child: Text(KaziLocalizations.current.edit),
                ),
                KaziSpacings.horizontalXs,
                PillButton(
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
                    RowText(
                      leftText: KaziLocalizations.current.myBalance,
                      rightText: NumberFormatUtils.formatCurrency(
                        context,
                        service.valueWithDiscount,
                      ),
                      rightTextStyle: Theme.of(
                        context,
                      ).textTheme.titleSmall!.copyWith(color: KaziColors.green),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: KaziInsets.lg),
                      child: Divider(),
                    ),
                    RowText(
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
                    RowText(
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
    );
  }
}
