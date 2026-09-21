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
import 'package:kazi/features/clients/presenter/widgets/client_order_bottom_sheet.dart';
import 'package:kazi/features/clients/presenter/widgets/clients_tip_card.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(clientsControllerProvider.notifier).onInit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientsControllerProvider);
    final controller = ref.read(clientsControllerProvider.notifier);

    return Scaffold(
      // The shell's own Scaffold does not resize for the keyboard, so this one
      // must not either — see `ServiceCatalogPage`, which has the same search
      // in the same place.
      resizeToAvoidBottomInset: false,
      body: KaziSafeArea(
        isScrollView: false,
        onRefresh: controller.onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isSearching)
              const _SearchBar()
            else
              _Header(state: state),
            KaziSpacings.verticalMd,
            // Off on `noData`: an empty account or an empty search already
            // answers with its own centred "Adicionar cliente" (`_Body`'s
            // `KaziEmpty`/`KaziNoResults`) — showing this one above it would
            // put the same action on screen twice. Off during search too, a
            // distraction-free narrowing view with no room for a second call
            // to action competing with the term being typed.
            if (!state.isSearching && state.status != BaseStateStatus.noData)
              // Edge to edge, not a pill squeezed into the header next to
              // search and the overflow menu — the one action this screen
              // exists for gets the width to itself instead of fighting two
              // other icons for room.
              Padding(
                padding: const EdgeInsets.only(bottom: KaziInsets.md),
                child: KaziElevatedButton.icon(
                  onTap: () => KaziNavigator.push(AppPage.addClient),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: KaziLocalizations.current.addClient,
                  width: double.infinity,
                ),
              ),
            Expanded(child: _Body(state: state)),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.state});

  final ClientsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientsControllerProvider.notifier);

    return SubNavBar(
      title: KaziLocalizations.current.clients,
      showBack: false,
      pills: [
        if (state.totalCount != null) _ClientCount(count: state.totalCount!),
        KaziSpacings.horizontalXs,
        KaziCircularButton.plain(
          onTap: controller.onOpenSearch,
          semantics: KaziLocalizations.current.search,
          child: Icon(LucideIcons.search, size: 18),
        ),
        KaziCircularButton.plain(
          onTap: () => KaziNavigator.showBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => ClientOrderBottomSheet(
              selectedOption: state.order,
              onPressed: (order) {
                KaziNavigator.pop();
                controller.onChangeOrder(order);
              },
            ),
          ),
          semantics: KaziLocalizations.current.orderBy,
          child: Icon(LucideIcons.arrowUpDown, size: 18),
        ),
        // The door to the archive is used once a quarter, so it never takes
        // the place of something read every week — and it disappears when
        // there is nothing behind it. This is load-bearing, not cosmetic:
        // `ArchivedClientsPage` auto-pops itself the moment its list reads
        // empty (a safety net for restoring the last item while already on
        // that screen), so opening it with nothing archived — which showing
        // this door at zero would invite — makes it flash open and
        // immediately bounce back. See core/archiving.md.
        KaziOverflowMenu(
          semantics: KaziLocalizations.current.actions,
          actions: [
            if (state.archivedCount > 0)
              KaziOverflowAction(
                label: KaziLocalizations.current.viewArchived(
                  state.archivedCount,
                ),
                icon: LucideIcons.archive,
                onTap: () => KaziNavigator.push(AppPage.archivedClients),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  static const _debounce = Duration(milliseconds: 400);

  final _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      ref.read(clientsControllerProvider.notifier).onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KaziBackButton(
          onTap: () {
            _timer?.cancel();
            ref.read(clientsControllerProvider.notifier).onCloseSearch();
          },
        ),
        KaziSpacings.horizontalXs,
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: KaziLocalizations.current.searchClientsHint,
              prefixIcon: Icon(LucideIcons.search, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final ClientsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientsControllerProvider.notifier);

    return switch (state.status) {
      BaseStateStatus.loading when state.clients.isEmpty =>
        const KaziSkeletonList(),
      BaseStateStatus.error when state.clients.isEmpty => KaziError(
        message: state.callbackMessage,
        onRetry: controller.onRefresh,
        scrollable: true,
      ),
      // A search that matched nothing is a cut with no rows, not an account
      // with no clients — so it offers to create what was typed instead of
      // the brand block.
      BaseStateStatus.noData when state.query.isNotEmpty => KaziNoResults(
        message: KaziLocalizations.current.nothingFoundFor(state.query),
        scrollable: true,
        actionLabel: KaziLocalizations.current.addClient,
        onAction: () => KaziNavigator.push(AppPage.addClient),
      ),
      // The nudge to build relationships belongs to the account that has
      // none yet, not to a list already full of them — it rides along with
      // the true empty state and nowhere else.
      BaseStateStatus.noData => const _EmptyClients(),
      _ => _ClientsList(state: state),
    };
  }
}

/// The true empty state — an account with no clients at all, not a search or
/// filter that matched nothing. The relationship nudge (`ClientsTipCard`)
/// rides along here and nowhere else: it belongs to the moment someone has
/// none yet, not to a list already full of them.
class _EmptyClients extends StatelessWidget {
  const _EmptyClients();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KaziEmpty(
                message: KaziLocalizations.current.noClientsFound,
                description: KaziLocalizations.current.noClientsDescription,
                action: KaziElevatedButton.label(
                  onTap: () => KaziNavigator.push(AppPage.addClient),
                  label: KaziLocalizations.current.addClient,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: KaziInsets.lg),
                child: ClientsTipCard(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// How many active clients the user owns, at the end of the header row.
class _ClientCount extends StatelessWidget {
  const _ClientCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: KaziLocalizations.current.clients,
      child: Text(
        count.toString(),
        style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
      ),
    );
  }
}

class _ClientsList extends ConsumerWidget {
  const _ClientsList({required this.state});

  final ClientsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = state.clients;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: clients.length,
      separatorBuilder: (context, index) => KaziSpacings.verticalXs,
      itemBuilder: (context, index) {
        final ClientEntry client = clients[index];
        return ClientListItem(
          client: client,
          currency: state.defaultCurrency,
          rateBook: state.rateBook,
          onTap: () => KaziNavigator.push(
            AppPage.clientDetails,
            extra: ClientArguments(client: client),
          ),
        );
      },
    );
  }
}
