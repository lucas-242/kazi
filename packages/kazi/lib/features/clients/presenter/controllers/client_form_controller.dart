import 'dart:async';

import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/utils/base_notifier.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/clients/domain/services/client_document_rule.dart';
import 'package:kazi/features/clients/domain/services/client_namesake_rule.dart';
import 'package:kazi/features/clients/presenter/controllers/client_details_controller.dart';
import 'package:kazi/features/clients/presenter/controllers/clients_controller.dart';
import 'package:kazi/features/subscription/presenter/controllers/paywall_prompt_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi/features/clients/domain/models/record_counters.dart';
import 'package:kazi_core/kazi_core.dart';

import 'client_form_state.dart';

part 'client_form_controller.g.dart';

@riverpod
class ClientFormController extends _$ClientFormController
    with BaseAsyncNotifier<ClientFormState> {
  ClientsRepository get _clientsRepository =>
      ref.read(clientsRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  /// The entry being edited (null when adding). Kept so an edit can rebuild the
  /// full [ClientEntry] preserving the service history and denormalized fields.
  ClientEntry? _originalClient;

  @override
  FutureOr<ClientFormState> build({ClientEntry? client}) {
    _originalClient = client;
    final user = client?.info.user;
    return ClientFormState(
      status: BaseStateStatus.readyToUserInput,
      clientId: client?.id,
      name: user?.name ?? '',
      phone: user?.phones.isNotEmpty ?? false ? user!.phones.first : '',
      email: user?.email ?? '',
      identifier: user?.identifier ?? '',
      observation: client?.observation ?? '',
      birthDate: ClientBirthDate.isMissing(user?.birthDate)
          ? null
          : user!.birthDate,
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

  void onChangeObservation(String value) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(observation: value));
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

      if (!current.isEditing) {
        final gate = await ref
            .read(freemiumGuardProvider)
            .checkAddClient(_authService.user!.uid);
        if (gate.isBlocked) {
          unawaited(
            ref
                .read(analyticsServiceProvider)
                .log(
                  AnalyticsEvent.limitReached,
                  parameters: {
                    'limit_type': gate.blockedBy!.name,
                    'form': 'client',
                  },
                ),
          );
          ref
              .read(paywallPromptControllerProvider.notifier)
              .promptFor(gate.blockedBy!);
          return;
        }
      }

      // After the limit, not before: a save the paywall is about to refuse has
      // no business spending a read on a duplicate check first.
      //
      // Not gated by the acknowledgement: agreeing to a namesake must never
      // carry a repeated document in with it.
      await ClientDocumentRule.ensureFree(
        _clientsRepository,
        ownerId: _authService.user!.uid,
        identifier: current.identifier,
        excludeClientId: current.clientId,
      );

      if (!current.namesakeAcknowledged) {
        final namesake = await _findNamesakeWarning(current);
        if (namesake != null) {
          state = AsyncData(current.copyWith(namesakeWarning: namesake));
          return;
        }
      }

      state = AsyncData(current.copyWith(status: BaseStateStatus.loading));

      final client = _buildUser(current);
      if (current.isEditing) {
        await _clientsRepository.update(
          current.clientId!,
          client,
          observation: current.observation.trim(),
        );
        final entry = _buildEntry(
          current.clientId!,
          client,
          current.observation.trim(),
        );
        ref.read(clientsControllerProvider.notifier).replaceClient(entry);
        ref
            .read(
              clientDetailsControllerProvider(
                clientId: current.clientId!,
              ).notifier,
            )
            .setClient(entry);
      } else {
        final id = await _clientsRepository.add(
          _authService.user!.uid,
          client,
          observation: current.observation.trim(),
        );
        ref
            .read(clientsControllerProvider.notifier)
            .appendClient(_buildEntry(id, client, current.observation.trim()));
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .log(
                AnalyticsEvent.clientCreated,
                parameters: const {'source': 'clients'},
              ),
        );
        await ref
            .read(creationAdCoordinatorProvider.future)
            .then((coordinator) => coordinator.onCreationAction());
      }

      state = AsyncData(current.copyWith(status: BaseStateStatus.success));
    } on AppError catch (exception) {
      onAppError(exception);
    } catch (exception) {
      unexpectedError(exception);
    }
  }

  /// The name of an active client already using this one's name, or null.
  ///
  /// Never blocks and never fails the save: a lookup that throws is reported as
  /// "no namesake", because refusing to save over a failed *warning* would cost
  /// the user their typing for nothing.
  Future<String?> _findNamesakeWarning(ClientFormState current) async {
    final namesake = await ClientNamesakeRule.find(
      _clientsRepository,
      ownerId: _authService.user!.uid,
      name: current.name,
      identifier: current.identifier,
      excludeClientId: current.clientId,
    );

    return namesake?.info.user.name;
  }

  /// Saves past the warning the user has now seen.
  Future<void> confirmNamesake() async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.withoutNamesakeWarning().copyWith(namesakeAcknowledged: true),
    );
    await save();
  }

  void dismissNamesakeWarning() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(current.withoutNamesakeWarning());
  }

  ClientEntry _buildEntry(String id, User user, String observation) {
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
      archivedAt: _originalClient?.archivedAt,
      counters: _originalClient?.counters ?? const RecordCounters(),
      observation: observation,
      createdAt: _originalClient?.createdAt,
    );
  }

  User _buildUser(ClientFormState current) {
    return User(
      id: 0,
      name: current.name.trim(),
      email: current.email.trim(),
      identifier: current.identifier.trim(),
      birthDate: current.birthDate ?? ClientBirthDate.missing,
      userType: UserType.client,
      authToken: '',
      refreshToken: '',
      authExpires: DateTime(2100),
      phones: [current.phone.trim()],
    );
  }

  void _checkValidity(ClientFormState current) {
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
