import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/agenda/domain/models/agenda_entry.dart';
import 'package:kazi/features/agenda/presenter/controllers/agenda_controller.dart';
import 'package:kazi/features/agenda/presenter/widgets/agenda_event_tile.dart';
import 'package:kazi/features/agenda/presenter/widgets/agenda_header.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The services laid out in time. See agenda/README.md.
class AgendaPage extends ConsumerStatefulWidget {
  const AgendaPage({super.key});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  late final KaziAgendaController _agenda;

  @override
  void initState() {
    super.initState();
    final state = ref.read(agendaControllerProvider);
    _agenda = KaziAgendaController(
      mode: state.mode,
      displayDate: state.firstVisibleDay,
    );
  }

  @override
  void dispose() {
    _agenda.dispose();
    super.dispose();
  }

  void _onChangeMode(KaziAgendaMode mode) {
    _agenda.mode = mode;
    ref.read(agendaControllerProvider.notifier).onChangeMode(mode);
  }

  void _openDay(DateTime day) {
    _onChangeMode(KaziAgendaMode.day);
    _agenda.show(day);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agendaControllerProvider);
    final controller = ref.read(agendaControllerProvider.notifier);
    final now = ref.watch(timeServiceProvider).now;

    return Scaffold(
      body: KaziSafeArea(
        isScrollView: false,
        child: Column(
          children: [
            AgendaHeader(
              state: state,
              onPickDate: _agenda.show,
              onPrevious: _agenda.backward,
              onToday: _agenda.today,
              onNext: _agenda.forward,
              onChangeMode: _onChangeMode,
            ),
            KaziSpacings.verticalSm,
            // Reserves its height either way, so the grid does not jump when
            // a read starts.
            SizedBox(
              height: 2,
              child: state.status == BaseStateStatus.loading
                  ? LinearProgressIndicator(
                      color: context.colors.text,
                      backgroundColor: context.colors.surfaceMuted,
                    )
                  : null,
            ),
            if (state.status == BaseStateStatus.error)
              KaziError(
                message: KaziLocalizations.current.errorToGetServices,
                onRetry: controller.onRefresh,
              ),
            Expanded(
              child: Padding(
                // The shell's centre button floats over the bottom of the tab.
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom,
                ),
                child: KaziAgenda<AgendaEntry>(
                  controller: _agenda,
                  events: state.entries,
                  eventBuilder: (context, entry, mode) =>
                      AgendaEventTile(entry: entry, mode: mode, now: now),
                  onEventTap: (entry) => KaziNavigator.push(
                    AppPage.serviceDetails,
                    extra: ServiceArguments(
                      service: entry.service,
                      previousPage: AppPage.agenda,
                    ),
                  ),
                  onDayTap: _openDay,
                  onVisibleRangeChanged: controller.onVisibleRangeChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
