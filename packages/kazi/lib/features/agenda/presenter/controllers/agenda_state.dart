import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/agenda/domain/models/agenda_entry.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class AgendaState extends BaseState with Equatable {
  AgendaState({
    required super.status,
    super.callbackMessage,
    required this.mode,
    required this.firstVisibleDay,
    required this.lastVisibleDay,
    this.services = const [],
  });

  final KaziAgendaMode mode;
  final DateTime firstVisibleDay;
  final DateTime lastVisibleDay;

  /// Every service loaded so far, across all the windows visited — not only
  /// the ones on screen. See [entries].
  final List<Service> services;

  /// What is drawn: the loaded services that fall on the visible days.
  List<AgendaEntry> get entries => [
    for (final service in services)
      if (AgendaEntry(service) case final entry
          when entry.fallsWithin(firstVisibleDay, lastVisibleDay))
        entry,
  ];

  @override
  AgendaState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    KaziAgendaMode? mode,
    DateTime? firstVisibleDay,
    DateTime? lastVisibleDay,
    List<Service>? services,
  }) {
    return AgendaState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      mode: mode ?? this.mode,
      firstVisibleDay: firstVisibleDay ?? this.firstVisibleDay,
      lastVisibleDay: lastVisibleDay ?? this.lastVisibleDay,
      services: services ?? this.services,
    );
  }

  @override
  List<Object?> get props => [
    status,
    callbackMessage,
    mode,
    firstVisibleDay,
    lastVisibleDay,
    services,
  ];
}
