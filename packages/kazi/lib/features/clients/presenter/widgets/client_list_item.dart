import 'package:flutter/material.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientListItem extends StatelessWidget {
  const ClientListItem({
    super.key,
    required this.client,
    required this.onTap,
    required this.onDelete,
  });

  final ClientEntry client;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  void _onLongPress(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => KaziDialog(
        title: KaziLocalizations.current.delete,
        message: KaziLocalizations.current.wouldYouLikeDelete(
          KaziLocalizations.current.thisClient,
        ),
        confirmText: KaziLocalizations.current.delete,
        onCancel: KaziNavigator.pop,
        onConfirm: () {
          KaziNavigator.pop();
          onDelete();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = client.info.user;
    final phone = user.phones.isNotEmpty ? user.phones.first : '';
    final lastServiceName = client.info.lastServiceName;

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _onLongPress(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(KaziInsets.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: KaziTextStyles.titleSmall),
                    if (lastServiceName.isNotEmpty) ...[
                      KaziSpacings.verticalXs,
                      Text(
                        '$lastServiceName • ${client.info.lastServiceDateFormatted}',
                        style: KaziTextStyles.bodySmall.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                    if (phone.isNotEmpty) ...[
                      KaziSpacings.verticalXs,
                      Text(
                        phone,
                        style: KaziTextStyles.bodySmall.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
