import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_state.dart';
import 'package:kazi/features/clients/presenter/widgets/archive_client_action.dart';
import 'package:kazi/features/clients/presenter/widgets/client_details_content.dart';
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

    Future<void> onTapArchive() async {
      final client = ref.read(provider).client;
      if (client == null) return;

      final archived = await archiveClientWithUndo(context, ref, client);
      if (archived) KaziNavigator.pop();
    }

    void onTapLoadMore() => ref.read(provider.notifier).loadMoreServices();

    final state = ref.watch(provider);

    return state.when(
      onState: (_) => _ClientDetails(
        state: state,
        onTapArchive: onTapArchive,
        onTapLoadMore: onTapLoadMore,
      ),
      onLoading: () => Scaffold(
        appBar: KaziAppBar(title: KaziLocalizations.current.details),
        body: const KaziSafeArea(isLoading: true),
      ),
      onNoData: () => KaziNoData(
        title: KaziLocalizations.current.details,
        message: KaziLocalizations.current.noClientsFound,
        fullPage: true,
      ),
      // A failed "load more" shouldn't wipe the already loaded details — the
      // listener above surfaces the message in a snackbar instead.
      onError: (_) => state.client == null
          ? KaziNoData(
              title: KaziLocalizations.current.details,
              message: KaziLocalizations.current.noClientsFound,
              fullPage: true,
            )
          : _ClientDetails(
              state: state,
              onTapArchive: onTapArchive,
              onTapLoadMore: onTapLoadMore,
            ),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  const _ClientDetails({
    required this.state,
    required this.onTapArchive,
    required this.onTapLoadMore,
  });

  final ClientDetailsState state;
  final VoidCallback onTapArchive;
  final VoidCallback onTapLoadMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KaziAppBar(
        title: KaziLocalizations.current.details,
        actions: [
          KaziCircularButton.plain(
            onTap: () => KaziNavigator.push(
              AppPage.addClient,
              extra: ClientArguments(client: state.client),
            ),
            child: const Icon(Icons.edit, size: 18),
          ),
          KaziSpacings.horizontalXs,
          KaziCircularButton.plain(
            onTap: onTapArchive,
            child: const Icon(Icons.archive_outlined, size: 18),
          ),
          KaziSpacings.horizontalXs,
        ],
      ),
      body: KaziSafeArea(
        child: ClientDetailsContent(
          client: state.client!,
          serviceHistory: state.serviceHistory,
          hasReachedMaxServices: state.hasReachedMaxServices,
          isLoadingMoreServices: state.isLoadingMoreServices,
          onTapLoadMore: onTapLoadMore,
        ),
      ),
    );
  }
}
