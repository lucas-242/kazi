import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_state.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientDetailsPage extends ConsumerWidget {
  const ClientDetailsPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = clientDetailsControllerProvider(clientId: clientId);

    ref.listen<ClientDetailsState>(provider, (previous, current) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    void onDelete() {
      KaziNavigator.pop();
      ref.read(clientsControllerProvider.notifier).deleteClient(clientId);
      KaziNavigator.pop();
    }

    void onTapDelete() {
      showDialog(
        context: context,
        builder: (_) => KaziDialog(
          title: KaziLocalizations.current.delete,
          message: KaziLocalizations.current.wouldYouLikeDelete(
            KaziLocalizations.current.thisClient,
          ),
          confirmText: KaziLocalizations.current.delete,
          onCancel: KaziNavigator.pop,
          onConfirm: onDelete,
        ),
      );
    }

    final state = ref.watch(provider);

    return Scaffold(
      body: KaziSafeArea(
        padding: const EdgeInsets.symmetric(
          horizontal: KaziInsets.lg,
          vertical: KaziInsets.lg,
        ),
        child: state.when(
          onState: (_) => _ClientDetailsContent(
            client: state.client!,
            onTapDelete: onTapDelete,
          ),
          onLoading: () => const Center(child: KaziLoading()),
          onNoData: () =>
              KaziNoData(message: KaziLocalizations.current.noClientsFound),
          onError: (_) =>
              KaziNoData(message: KaziLocalizations.current.noClientsFound),
        ),
      ),
    );
  }
}

class _ClientDetailsContent extends StatelessWidget {
  const _ClientDetailsContent({
    required this.client,
    required this.onTapDelete,
  });

  final ClientEntry client;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    final user = client.info.user;
    final phone = user.phones.isNotEmpty ? user.phones.first : '';
    final hasBirthDate = user.birthDate.year > 2000;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubNavBar(
            title: KaziLocalizations.current.details,
            pills: [
              KaziPillButton(
                onTap: () => KaziNavigator.push(
                  AppPage.addClient,
                  extra: ClientArguments(client: client),
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
          if (client.info.serviceHistory.isEmpty)
            Text(
              KaziLocalizations.current.noServicesYet,
              style: KaziTextStyles.sm.copyWith(color: KaziColors.grey),
            )
          else
            ...client.info.serviceHistory.map(
              (service) => _ServiceHistoryTile(service: service),
            ),
        ],
      ),
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

class _ServiceHistoryTile extends StatelessWidget {
  const _ServiceHistoryTile({required this.service});

  final ServiceHistoryItem service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(KaziInsets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
  }
}
