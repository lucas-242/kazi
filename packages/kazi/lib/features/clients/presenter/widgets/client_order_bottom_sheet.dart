import 'package:flutter/material.dart';
import 'package:kazi/features/clients/domain/models/client_order.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The Clients tab's own order-by sheet — same shape as Services'
/// `OrderByBottomSheet`, opened from the same kind of icon in the header,
/// so the two lists teach one behaviour instead of two.
class ClientOrderBottomSheet extends StatelessWidget {
  const ClientOrderBottomSheet({
    super.key,
    required this.onPressed,
    required this.selectedOption,
  });

  final void Function(ClientOrder) onPressed;
  final ClientOrder selectedOption;

  Map<ClientOrder, String> get orderOptions => {
    ClientOrder.lastService: KaziLocalizations.current.orderLastService,
    ClientOrder.alphabetical: KaziLocalizations.current.orderAlphabetical,
    ClientOrder.topEarning: KaziLocalizations.current.orderTopEarning,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: KaziInsets.xLg,
            right: KaziInsets.xLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                KaziLocalizations.current.orderBy,
                style: KaziTextStyles.titleMedium,
              ),
              KaziSpacings.verticalXLg,
              ListView.separated(
                shrinkWrap: true,
                itemCount: orderOptions.length,
                itemBuilder: (context, index) {
                  final order = orderOptions.keys.elementAt(index);
                  final isSelected = selectedOption == order;
                  return GestureDetector(
                    onTap: () => onPressed(order),
                    child: ListTile(
                      title: Text(
                        orderOptions.values.elementAt(index),
                        style: isSelected
                            ? KaziTextStyles.titleMedium
                            : KaziTextStyles.bodyMedium,
                      ),
                      trailing: Visibility(
                        visible: isSelected,
                        child: Icon(
                          LucideIcons.check,
                          color: context.colors.brand.text,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
