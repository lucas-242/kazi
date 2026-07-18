import 'dart:async';

import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import 'client_form_state.dart';

part 'client_form_controller.g.dart';

@riverpod
class ClientFormController extends _$ClientFormController
    with BaseAsyncNotifier<ClientFormState> {
  ClientsRepository get _clientsRepository => ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  /// The entry being edited (null when adding). Kept so an edit can rebuild the
  /// full [ClientEntry] preserving the service history and denormalized fields.
  ClientEntry? _originalClient;

  @override
  FutureOr<ClientFormState> build({ClientEntry? client}) {
    _originalClient = client;
    final user = client?.info.user;
    final birthDate = user?.birthDate;
    return ClientFormState(
      status: BaseStateStatus.readyToUserInput,
      clientId: client?.id,
      name: user?.name ?? '',
      phone: user?.phones.isNotEmpty ?? false ? user!.phones.first : '',
      email: user?.email ?? '',
      identifier: user?.identifier ?? '',
      // Stored clients without a birth date fall back to DateTime(2000).
      birthDate: (birthDate != null && birthDate.year > 2000)
          ? birthDate
          : null,
    );
  }

  void onChangeName(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(name: value));
  }

  void onChangePhone(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(phone: value));
  }

  void onChangeEmail(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(email: value));
  }

  void onChangeIdentifier(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(identifier: value));
  }

  void onChangeBirthDate(DateTime value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(birthDate: value));
  }

  Future<void> save() async {
    final current = state.asData?.value;
    if (current == null) return;

    try {
      _checkValidity(current);
      state = AsyncData(current.copyWith(status: BaseStateStatus.loading));

      final client = _buildUser(current);
      if (current.isEditing) {
        await _clientsRepository.update(current.clientId!, client);
        final entry = _buildEntry(current.clientId!, client);
        ref.read(clientsControllerProvider.notifier).replaceClient(entry);
        ref
            .read(
              clientDetailsControllerProvider(clientId: current.clientId!)
                  .notifier,
            )
            .setClient(entry);
      } else {
        await _clientsRepository.add(_authService.user!.uid, client);
        // Add isn't optimistic: the new doc id comes from the backend and the
        // list is name-ordered/paginated, so we refetch to place it correctly.
        ref.read(clientsControllerProvider.notifier).onRefresh();
      }

      state = AsyncData(current.copyWith(status: BaseStateStatus.success));
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// Rebuilds the [ClientEntry] after an edit, merging the new [user] fields
  /// into the original entry's [ClientInfo] so the service history and
  /// denormalized last-service fields are preserved.
  ClientEntry _buildEntry(String id, User user) {
    final base = _originalClient?.info;
    return (
      id: id,
      info: ClientInfo(
        user: user,
        lastServiceName: base?.lastServiceName ?? '',
        lastServiceDate: base?.lastServiceDate ?? DateTime(2000),
        mostUsedServices: base?.mostUsedServices ?? const {},
        serviceHistory: base?.serviceHistory ?? const [],
      ),
    );
  }

  User _buildUser(ClientFormState current) {
    return User(
      id: 0,
      name: current.name.trim(),
      email: current.email.trim(),
      identifier: current.identifier.trim(),
      birthDate: current.birthDate ?? DateTime(2000),
      userType: UserType.client,
      authToken: '',
      refreshToken: '',
      authExpires: DateTime(2100),
      phones: [current.phone.trim()],
    );
  }

  void _checkValidity(ClientFormState current) {
    if (current.identifier.trim().isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.cpfCnpj,
        ),
      );
    }
    if (current.name.trim().isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.name,
        ),
      );
    }
    if (current.phone.trim().isEmpty) {
      throw ClientError(
        KaziLocalizations.current.requiredProperty(
          KaziLocalizations.current.phone,
        ),
      );
    }
  }
}
