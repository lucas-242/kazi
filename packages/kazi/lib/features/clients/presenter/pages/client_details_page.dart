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

    Future<void> onRefresh() => ref.read(provider.notifier).onRefresh();

    final state = ref.watch(provider);

    return state.when(
      onState: (_) => _ClientDetails(
        state: state,
        onTapArchive: onTapArchive,
        onTapLoadMore: onTapLoadMore,
        onRefresh: onRefresh,
      ),
      onLoading: () => Scaffold(
        appBar: KaziAppBar(title: KaziLocalizations.current.details),
        body: const KaziSafeArea(isLoading: true),
      ),
      onNoData: () => KaziEmpty(
        title: KaziLocalizations.current.details,
        message: KaziLocalizations.current.noClientsFound,
        fullPage: true,
        onRefresh: onRefresh,
      ),
      // A failed "load more" shouldn't wipe the already loaded details — the
      // listener above surfaces the message in a snackbar instead.
      onError: (_) => state.client == null
          ? KaziEmpty(
              title: KaziLocalizations.current.details,
              message: KaziLocalizations.current.noClientsFound,
              fullPage: true,
              onRefresh: onRefresh,
            )
          : _ClientDetails(
              state: state,
              onTapArchive: onTapArchive,
              onTapLoadMore: onTapLoadMore,
              onRefresh: onRefresh,
            ),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  const _ClientDetails({
    required this.state,
    required this.onTapArchive,
    required this.onTapLoadMore,
    required this.onRefresh,
  });

  final ClientDetailsState state;
  final VoidCallback onTapArchive;
  final VoidCallback onTapLoadMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KaziAppBar(
        title: state.client?.info.user.name ?? KaziLocalizations.current.client,
        actions: [
          KaziCircularButton.plain(
            onTap: () => KaziNavigator.push(
              AppPage.addClient,
              extra: ClientArguments(client: state.client),
            ),
            semantics: KaziLocalizations.current.edit,
            child: const Icon(Icons.edit, size: 18),
          ),
          // Archiving is rare and destructive: available without being in
          // evidence. See core/archiving.md.
          KaziOverflowMenu(
            semantics: KaziLocalizations.current.actions,
            actions: [
              KaziOverflowAction(
                label: KaziLocalizations.current.archive,
                icon: Icons.archive_outlined,
                isDestructive: true,
                onTap: onTapArchive,
              ),
            ],
          ),
          KaziSpacings.horizontalXs,
        ],
      ),
      body: KaziSafeArea(
        onRefresh: onRefresh,
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
