import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/received_mark.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

/// One line of the services list: the commission as the headline, the gross as
/// the footnote, the category in the leading bar.
/// See `features/services/README.md`.
///
/// ```
/// ▏ Alongamento em gel            R$ 81
/// ▏ Marina R. · 09 ago         de R$ 180
/// ```
class ServiceCard extends ConsumerWidget {
  const ServiceCard({super.key, required this.onTap, required this.service});
  final VoidCallback onTap;
  final Service service;

  /// "Marina R. · 09 ago", or just the date when the service has no client.
  String _subtitle() {
    final date = DateFormat.yMd().format(service.date).normalizeDate();
    final client = service.clientName ?? '';
    return client.isEmpty ? date : '$client · $date';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final defaultCurrency = ref.watch(kaziDefaultCurrencyProvider);
    final serviceCurrency = service.currencyOr(defaultCurrency);

    return Material(
      color: colors.card,
      borderRadius: KaziRadii.smBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: KaziRadii.smBorder,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
          ),
          // Clipped so the bar takes the card's rounded corner rather than
          // squaring off the leading edge.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: KaziRadii.smBorder,
            border: Border.all(color: colors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KaziCategoryBar(color: service.catalogItem?.colorAs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KaziInsets.md,
                      vertical: KaziInsets.sm,
                    ),
                    child: _Content(
                      service: service,
                      currency: serviceCurrency,
                      subtitle: _subtitle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.service,
    required this.currency,
    required this.subtitle,
  });

  final Service service;
  final SupportedCurrency currency;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                service.catalogItem?.name ?? '',
                style: KaziTextStyles.titleSmall,
              ),
              KaziSpacings.verticalXxs,
              // One span, so the situation ellipsises with the line it belongs
              // to instead of pushing the amounts out of their column.
              Text.rich(
                TextSpan(
                  text: subtitle,
                  children: [
                    if (service.isReceived) receivedMarkSpan(context),
                  ],
                ),
                style: KaziTextStyles.labelSmall.copyWith(
                  color: colors.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        KaziSpacings.horizontalSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormatUtils.formatCurrencyIn(
                service.commissionValue,
                currency,
              ),
              style: KaziTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            KaziSpacings.verticalXxs,
            Text(
              KaziLocalizations.current.ofGross(
                NumberFormatUtils.formatCurrencyIn(service.value, currency),
              ),
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
