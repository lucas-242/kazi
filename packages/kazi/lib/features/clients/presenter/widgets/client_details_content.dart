import 'package:flutter/material.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientDetailsContent extends StatelessWidget {
  const ClientDetailsContent({
    super.key,
    required this.client,
    required this.serviceHistory,
    required this.hasReachedMaxServices,
    required this.isLoadingMoreServices,
    required this.onTapLoadMore,
    required this.onTapDelete,
  });

  final ClientEntry client;
  final List<ServiceHistoryItem> serviceHistory;
  final bool hasReachedMaxServices;
  final bool isLoadingMoreServices;
  final VoidCallback onTapLoadMore;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    final user = client.info.user;
    final phone = user.phones.isNotEmpty ? user.phones.first : '';
    final hasBirthDate = user.birthDate.year > 2000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: KaziLocalizations.current.name, value: user.name),
        KaziSpacings.verticalMd,
        _InfoRow(
          label: KaziLocalizations.current.phone,
          value: phone.isEmpty ? '-' : phone,
        ),
        if (user.email.isNotEmpty) ...[
          KaziSpacings.verticalMd,
          _InfoRow(label: KaziLocalizations.current.email, value: user.email),
        ],
        if (user.identifier.isNotEmpty) ...[
          KaziSpacings.verticalMd,
          _InfoRow(
            label: KaziLocalizations.current.cpfCnpj,
            value: user.identifier,
          ),
        ],
        if (hasBirthDate) ...[
          KaziSpacings.verticalMd,
          _InfoRow(
            label: KaziLocalizations.current.birthDate,
            value:
                '${user.birthDate.day.toString().padLeft(2, '0')}/${user.birthDate.month.toString().padLeft(2, '0')}/${user.birthDate.year}',
          ),
        ],
        KaziSpacings.verticalXLg,
        Text(
          KaziLocalizations.current.lastServices,
          style: KaziTextStyles.titleMd,
        ),
        KaziSpacings.verticalMd,
        if (serviceHistory.isEmpty)
          Text(
            KaziLocalizations.current.noServicesYet,
            style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
          )
        else ...[
          _ServiceHistory(serviceHistory: serviceHistory),
          if (!hasReachedMaxServices)
            Center(
              child: isLoadingMoreServices
                  ? const Padding(
                      padding: EdgeInsets.all(KaziInsets.sm),
                      child: KaziLoading(),
                    )
                  : KaziTextButton(
                      onTap: onTapLoadMore,
                      child: Text(KaziLocalizations.current.loadMore),
                    ),
            ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KaziTextStyles.sm.copyWith(color: KaziColors.grey)),
        KaziSpacings.verticalXs,
        Text(value, style: KaziTextStyles.md),
      ],
    );
  }
}

class _ServiceHistory extends StatelessWidget {
  const _ServiceHistory({required this.serviceHistory});

  final List<ServiceHistoryItem> serviceHistory;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: serviceHistory.length,
      separatorBuilder: (_, _) => Divider(color: KaziColors.stroke),
      itemBuilder: (_, index) {
        final service = serviceHistory[index];
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KaziInsets.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(service.serviceName, style: KaziTextStyles.titleSm),
                KaziSpacings.verticalXs,
                Text(
                  service.formattedDate,
                  style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
