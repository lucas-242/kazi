import 'package:flutter/material.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// One line of the clients list: who was seen last and when, and what they have
/// earned the user across everything.
///
/// ```
/// Marina Rocha                       R$ 1.840
/// Último em 09 ago · 12 serviços
/// ```
///
/// No category bar — a client has no type to carry. See core/counters.md for
/// where the figures come from.
class ClientListItem extends StatelessWidget {
  const ClientListItem({
    super.key,
    required this.client,
    required this.currency,
    required this.rateBook,
    required this.onTap,
    required this.onArchive,
  });

  final ClientEntry client;
  final SupportedCurrency currency;
  final RateBook rateBook;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  /// "Último em 09 ago · 12 serviços", or the invitation when they have none.
  String _subtitle() {
    final counters = client.counters;
    if (counters.count == 0) return KaziLocalizations.current.noServiceYet;

    final last = KaziLocalizations.current.lastServiceOn(
      client.info.lastServiceDateFormatted,
    );
    return '$last · ${KaziLocalizations.current.servicesCount(counters.count)}';
  }

  /// Null while the counters have never been written, and when no rate can
  /// convert them — an amount is better absent than wrong.
  String? _amount() {
    final counters = client.counters;
    if (counters.isMissing) return null;

    final total = counters.commissionIn(
      currency,
      rateBook: rateBook,
      legacyCurrency: currency,
      dateKey: ExchangeRates.dateKeyOf(DateTime.now()),
    );
    if (total.unconverted > 0 && total.amount == 0) return null;

    return NumberFormatUtils.formatCurrencyIn(total.amount, currency);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amount = _amount();

    return Material(
      color: colors.card,
      borderRadius: KaziRadii.smBorder,
      child: InkWell(
        onTap: onTap,
        onLongPress: onArchive,
        borderRadius: KaziRadii.smBorder,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: KaziSizings.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: KaziInsets.md,
            vertical: KaziInsets.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: KaziRadii.smBorder,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.info.user.name,
                      style: KaziTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    KaziSpacings.verticalXxs,
                    Text(
                      _subtitle(),
                      style: KaziTextStyles.labelSmall.copyWith(
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (amount != null) ...[
                KaziSpacings.horizontalSm,
                Text(
                  amount,
                  style: KaziTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
