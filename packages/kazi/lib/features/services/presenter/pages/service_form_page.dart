import 'package:flutter/material.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/core/widgets/tap_probe.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_controller.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_state.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_form_content.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class ServiceFormPage extends ConsumerStatefulWidget {
  const ServiceFormPage({super.key, this.service});

  final Service? service;

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  bool isCreating(Service? service) => service?.id.isEmpty ?? true;

  void onConfirm(Service service, {bool ignoreConflicts = false}) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = serviceFormControllerProvider(service: widget.service);
    if (isCreating(service)) {
      ref.read(provider.notifier).addService(ignoreConflicts: ignoreConflicts);
    } else {
      ref
          .read(provider.notifier)
          .updateService(ignoreConflicts: ignoreConflicts);
    }
  }

  /// "Corte · 14:00–15:30", with the dates when a booking spans days.
  String _conflictLine(Service service, ServiceFormState state) {
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat.Hm(locale);
    final block = service.agendaBlock!;
    final name =
        service.catalogItem?.name ??
        state.catalogItems
            .where((item) => item.id == service.catalogItemId)
            .map((item) => item.name)
            .firstOrNull ??
        KaziLocalizations.current.service;

    String at(DateTime moment) => service.isMultiDay
        ? '${DateFormatUtils.day(moment, locale: locale)} ${time.format(moment)}'
        : time.format(moment);

    return '$name · ${at(block.start)}–${at(block.end)}';
  }

  /// Warns, never blocks: two bookings at once is sometimes the plan — a
  /// professional with an assistant. Closing the dialog any way clears the
  /// conflicts, so the next save looks them up afresh.
  Future<void> _showConflicts(ServiceFormState state) async {
    final provider = serviceFormControllerProvider(service: widget.service);
    final lines = state.conflicts
        .map((service) => _conflictLine(service, state))
        .join('\n');

    await showDialog<void>(
      context: context,
      builder: (context) => KaziDialog(
        title: KaziLocalizations.current.scheduleConflictTitle,
        message: KaziLocalizations.current.scheduleConflictMessage(lines),
        confirmText: KaziLocalizations.current.saveAnyway,
        onCancel: KaziNavigator.pop,
        onConfirm: () {
          KaziNavigator.pop();
          // Cleared before the save starts, or the save would copy them back.
          ref.read(provider.notifier).dismissConflicts();
          onConfirm(state.service, ignoreConflicts: true);
        },
      ),
    );
    ref.read(provider.notifier).dismissConflicts();
  }

  @override
  Widget build(BuildContext context) {
    final provider = serviceFormControllerProvider(service: widget.service);

    ref.listen<AsyncValue<ServiceFormState>>(provider, (previous, current) {
      final state = current.asData?.value;
      final hadConflicts =
          previous?.asData?.value.conflicts.isNotEmpty ?? false;
      if (state != null && state.conflicts.isNotEmpty && !hadConflicts) {
        _showConflicts(state);
      }

      final previousStatus = previous?.asData?.value.status;
      final currentStatus = current.asData?.value.status;
      if (previousStatus == currentStatus) return;

      if (currentStatus == BaseStateStatus.success) {
        ref.read(serviceLandingControllerProvider.notifier).onChangeServices();
        ref.read(dashboardControllerProvider.notifier).onRefresh();
        KaziNavigator.pop();
      } else if (currentStatus == BaseStateStatus.error) {
        final message = current.asData?.value.callbackMessage ?? '';
        if (message.isNotEmpty) {
          KaziSnackbar.show(context, message);
        }
      }
    });

    final asyncState = ref.watch(provider);
    final state = asyncState.asData?.value;
    final isSaving = state?.status == BaseStateStatus.loading;

    return Scaffold(
      appBar: KaziAppBar(
        leading: const KaziCloseButton(),
        title: isCreating(widget.service)
            ? KaziLocalizations.current.registerService
            : KaziLocalizations.current.editService,
      ),
      body: KaziSafeArea(
        // Only while loading or saving: a refused save leaves the status at
        // error, and the form has to stay usable for the correction.
        isLoading: state == null || state.status == BaseStateStatus.loading,
        child: state == null
            ? const SizedBox.shrink()
            : ServiceFormContent(
                service: widget.service,
                isCreating: isCreating(widget.service),
                formKey: _formKey,
              ),
      ),
      bottomNavigationBar: state == null
          ? null
          : KaziFormFooter(
              label: isSaving
                  ? KaziLocalizations.current.saving
                  : isCreating(widget.service)
                  ? KaziLocalizations.current.registerService
                  : KaziLocalizations.current.save,
              // Null while the write is in flight: a second tap would register
              // the service twice if the first one is slow.
              onTap: isSaving ? null : () => onConfirm(state.service),
              child: (button) =>
                  TapProbe(target: 'save_service', child: button),
            ),
    );
  }
}
