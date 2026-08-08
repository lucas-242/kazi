import 'package:flutter/material.dart';
import 'package:kazi_companies/core/components/most_used_services.dart';
import 'package:kazi_companies/core/components/personal_info_card/personal_info_card.dart';
import 'package:kazi_companies/presenter/clients/components/services_history.dart';
import 'package:kazi_companies/presenter/clients/controllers/client_details_controller.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientDetailsPage extends ConsumerWidget {
  const ClientDetailsPage({super.key, this.client, this.clientId});
  final String? clientId;
  final ClientInfo? client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        ref.watch(clientDetailsControllerProvider(clientId, client));

    return provider.when(
      loading: () => const KaziLoading(),
      error: (error, stackTrace) => KaziError(message: error.toString()),
      data: (state) => KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PersonalInfoCard(user: state.user),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KaziInsets.xLg),
                child: Column(
                  spacing: KaziInsets.md,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Serviços Mais Realizados',
                      style: KaziTextStyles.headlineSm,
                    ),
                    MostUsedServices(
                      items: state.mostUsedServices,
                    ),
                  ],
                ),
              ),
            ),
            ServicesHistory(clientInfo: state),
          ],
        ),
      ),
    );
  }
}
