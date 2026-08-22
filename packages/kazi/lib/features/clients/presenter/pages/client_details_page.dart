import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_state.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
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
          isDestructive: true,
          onCancel: KaziNavigator.pop,
          onConfirm: onDelete,
        ),
      );
    }

    void onTapLoadMore() => ref.read(provider.notifier).loadMoreServices();

    final state = ref.watch(provider);

    return state.when(
      onState: (_) => _ClientDetails(
        state: state,
        onTapDelete: onTapDelete,
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
              onTapDelete: onTapDelete,
              onTapLoadMore: onTapLoadMore,
            ),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  const _ClientDetails({
    required this.state,
    required this.onTapDelete,
    required this.onTapLoadMore,
  });

  final ClientDetailsState state;
  final VoidCallback onTapDelete;
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
            onTap: onTapDelete,
            child: const Icon(Icons.delete, size: 18),
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
          onTapDelete: onTapDelete,
        ),
      ),
    );
  }
}
