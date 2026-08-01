import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi/features/clients/clients.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_state.dart';
import 'package:kazi/features/clients/presenter/widgets/client_list_item.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(clientsControllerProvider.notifier).onInit(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(clientsControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(clientsControllerProvider.notifier).onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ClientsState>(clientsControllerProvider, (previous, current) {
      if (previous?.status != current.status &&
          current.status == BaseStateStatus.error) {
        KaziSnackbar.show(context, current.callbackMessage);
      }
    });

    final state = ref.watch(clientsControllerProvider);

    return Scaffold(
      body: KaziSafeArea(
        isScrollView: false,
        onRefresh: () =>
            ref.read(clientsControllerProvider.notifier).onRefresh(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubNavBar(
              title: KaziLocalizations.current.clients,
              pills: [
                KaziCircularButton(
                  onTap: () => KaziNavigator.push(AppPage.addClient),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            KaziSpacings.verticalMd,
            KaziTextFormField(
              labelText: KaziLocalizations.current.searchByName,
              prefixIcon: const Icon(Icons.search),
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
            ),
            KaziSpacings.verticalMd,
            Expanded(
              child: state.when(
                onState: (_) => _ClientsList(
                  state: state,
                  scrollController: _scrollController,
                ),
                onLoading: () => const Center(child: KaziLoading()),
                onNoData: () => KaziNoData(
                  message: KaziLocalizations.current.noClientsFound,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientsList extends ConsumerWidget {
  const _ClientsList({required this.state, required this.scrollController});

  final ClientsState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = state.clients;

    return ListView.builder(
      controller: scrollController,
      itemCount: clients.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= clients.length) {
          return const Padding(
            padding: EdgeInsets.all(KaziInsets.lg),
            child: Center(child: KaziLoading()),
          );
        }

        final ClientEntry client = clients[index];
        return ClientListItem(
          client: client,
          onTap: () => KaziNavigator.push(
            AppPage.clientDetails,
            extra: ClientArguments(client: client),
          ),
          onDelete: () => ref
              .read(clientsControllerProvider.notifier)
              .deleteClient(client.id),
        );
      },
    );
  }
}
