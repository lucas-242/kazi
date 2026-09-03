import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/models/record_counters.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Builds a [ClientEntry] with only the fields the clients feature reads.
///
/// [ClientInfo] wraps kazi_core's [User], which needs nine required arguments
/// that mean nothing here — this hides them behind sensible values so a test
/// only states what it is actually asserting on.
ClientEntry clientEntryMock({
  required String id,
  String? name,
  String email = 'client@test.com',
  String identifier = '',
  List<String> phones = const [],
  DateTime? birthDate,
  String lastServiceName = '',
  DateTime? lastServiceDate,
  Map<String, int> mostUsedServices = const {},
  List<ServiceHistoryItem> serviceHistory = const [],
  DateTime? archivedAt,
  RecordCounters counters = const RecordCounters(),
  String observation = '',
  DateTime? createdAt,
}) {
  return (
    id: id,
    archivedAt: archivedAt,
    counters: counters,
    observation: observation,
    info: ClientInfo(
      user: User(
        id: 0,
        name: name ?? 'Client $id',
        email: email,
        phones: phones,
        document: identifier,
        birthDate: birthDate ?? DateTime(1990),
        createdAt: createdAt,
        userType: UserType.client,
        authToken: '',
        refreshToken: '',
        authExpires: DateTime(2100),
      ),
      lastServiceName: lastServiceName,
      lastServiceDate: lastServiceDate ?? DateTime(2026, 6),
      mostUsedServices: mostUsedServices,
      serviceHistory: serviceHistory,
    ),
  );
}

/// [count] clients named `Client 00`, `Client 01`, … so the name ordering the
/// repository promises is also the list order a test can assert on.
List<ClientEntry> clientEntriesMock(int count, {int startAt = 0}) => [
  for (var index = startAt; index < startAt + count; index++)
    clientEntryMock(
      id: '$index',
      name: 'Client ${index.toString().padLeft(2, '0')}',
    ),
];
