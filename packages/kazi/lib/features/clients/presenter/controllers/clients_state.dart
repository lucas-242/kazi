import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/models/client_order.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ClientsState extends BaseState {
  ClientsState({
    required super.status,
    super.callbackMessage,
    List<ClientEntry>? clients,
    this.query = '',
    this.isSearching = false,
    this.order = ClientOrder.lastService,
    this.defaultCurrency = SupportedCurrency.usd,
    this.rateBook = const RateBook.empty(),
    this.totalCount,
    this.archivedCount = 0,
  }) : clients = clients ?? [];

  /// Already ordered — see `ClientsController.onChangeOrder`, which does the
  /// sorting the backend cannot.
  final List<ClientEntry> clients;
  final String query;

  /// Whether the header is a search field rather than a title.
  final bool isSearching;

  final ClientOrder order;

  /// Currency the lifetime figures are shown in, and the rates that get them
  /// there. See core/counters.md.
  final SupportedCurrency defaultCurrency;
  final RateBook rateBook;

  /// Every active client the user owns, not just the loaded page — and not
  /// narrowed by a search. `null` until the count comes back (or when it
  /// failed, which never blocks the listing).
  final int? totalCount;

  /// Archived clients the user owns. Zero hides the way into the archive, so a
  /// failed count reads as "nothing archived" rather than opening an empty
  /// screen.
  final int archivedCount;

  @override
  ClientsState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<ClientEntry>? clients,
    String? query,
    bool? isSearching,
    ClientOrder? order,
    SupportedCurrency? defaultCurrency,
    RateBook? rateBook,
    int? totalCount,
    int? archivedCount,
  }) {
    return ClientsState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      clients: clients ?? this.clients,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      order: order ?? this.order,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      rateBook: rateBook ?? this.rateBook,
      totalCount: totalCount ?? this.totalCount,
      archivedCount: archivedCount ?? this.archivedCount,
    );
  }
}
