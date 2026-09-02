import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/option_tile.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/controllers/service_form_controller.dart';
import 'package:kazi/features/services/presenter/widgets/quick_add_sheet.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Quick-add sheet to create a client without leaving the service form. On
/// success the new client is appended to the form's dropdown (no refetch) and
/// auto-selected; validation/creation errors are shown as a snackbar.
///
/// Name and phone are required, the document is not: a client with no way to
/// be reached is a row that only takes up space, and the number is asked once,
/// while the person is still in front of you.
///
/// A namesake is answered here rather than found later as a second row — see
/// README.md.
class AddClientSheet extends ConsumerStatefulWidget {
  const AddClientSheet({super.key, required this.service});

  /// The service that keys the [serviceFormControllerProvider] family.
  final Service? service;

  @override
  ConsumerState<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends ConsumerState<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _identifierKey = GlobalKey<FormFieldState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _phoneKey = GlobalKey<FormFieldState>();
  final _identifierController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _saving = false;

  /// The date a client with no service at all is stored under, which is a
  /// sentinel and not a day anybody was served.
  static final DateTime _noLastService = DateTime(2001);

  /// The client already carrying the typed name, once the lookup has found
  /// one. Its presence is what puts the two options on screen.
  ClientNamesake? _namesake;

  /// Which of the two the user picked. Starts on "create anyway", the answer
  /// the sheet was already on its way to giving.
  bool _useNamesake = false;

  ServiceFormController get _controller => ref.read(
    serviceFormControllerProvider(service: widget.service).notifier,
  );

  @override
  void dispose() {
    _identifierController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Dropped the moment the name changes: a warning about a name nobody is
  /// typing any more is worse than none.
  void _onChangeName(String _) {
    if (_namesake == null) return;
    setState(() {
      _namesake = null;
      _useNamesake = false;
    });
  }

  Future<void> _onConfirm() async {
    if (_saving) return;

    // Before the validation, not after: reusing a client creates nothing, so
    // the phone of the client that is not being created has nothing to say.
    if (_useNamesake) {
      _controller.useExistingClient(_namesake!.client);
      KaziNavigator.pop();
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Asked once: past this the user has seen the warning and answered it, so
    // a second tap is the decision to create the namesake.
    if (_namesake == null) {
      final namesake = await _controller.findClientNamesake(
        name: _nameController.text,
        identifier: _identifierController.text,
      );
      if (!mounted) return;
      if (namesake != null) {
        setState(() {
          _saving = false;
          _namesake = namesake;
        });
        return;
      }
    }

    try {
      await _controller.quickAddClient(
        identifier: _identifierController.text,
        name: _nameController.text,
        phone: _phoneController.text,
      );
      if (mounted) KaziNavigator.pop();
    } on AppError catch (exception) {
      if (mounted) {
        setState(() => _saving = false);
        KaziSnackbar.show(context, exception.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    }
  }

  /// What makes the namesake recognizable, in the order the person can act on.
  ///
  /// The count is the strongest — "com 12 serviços" places the person at
  /// once. Failing that the last service and its date, both already on the
  /// document the search returned. Failing that the bare name, which is still
  /// better than a zero the user would believe.
  String _namesakeMessage(BuildContext context, ClientNamesake namesake) {
    final l10n = KaziLocalizations.current;
    final client = namesake.client;
    final name = client.info.user.name;

    // Above zero, not merely present: a client with no service yet is one the
    // count says nothing about, and "com 0 serviços" reads as a wrong fact.
    final count = namesake.serviceCount ?? 0;
    if (count > 0) return l10n.clientNamesake(count, name);

    final lastService = client.info.lastServiceName;
    final lastDate = client.info.lastServiceDate;
    if (lastService.isNotEmpty && lastDate.isAfter(_noLastService)) {
      return l10n.clientNamesakeLastService(
        name,
        lastService,
        DateFormatUtils.day(
          lastDate,
          locale: Localizations.localeOf(context).toString(),
        ),
      );
    }

    return l10n.clientNamesakePlain(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final namesake = _namesake;

    return QuickAddSheet(
      title: l10n.newClient,
      formKey: _formKey,
      isSaving: _saving,
      onConfirm: _onConfirm,
      confirmLabel: _useNamesake ? l10n.confirm : null,
      children: [
        KaziFieldInput(
          fieldKey: _nameKey,
          label: l10n.name,
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: _onChangeName,
          validator: (value) =>
              FormValidator.validateTextField(value, l10n.name),
        ),
        if (namesake != null) ...[
          KaziSpacings.verticalXs,
          KaziNote(_namesakeMessage(context, namesake)),
          KaziSpacings.verticalXs,
          OptionTile(
            label: l10n.useExistingClient(namesake.client.info.user.name),
            mark: OptionMark.radio,
            selected: _useNamesake,
            onTap: () => setState(() => _useNamesake = true),
          ),
          OptionTile(
            label: l10n.createAnyway,
            mark: OptionMark.radio,
            selected: !_useNamesake,
            onTap: () => setState(() => _useNamesake = false),
          ),
        ],
        KaziSpacings.verticalXs,
        KaziFieldInput(
          fieldKey: _phoneKey,
          label: l10n.phone,
          controller: _phoneController,
          placeholder: l10n.phoneHint,
          keyboardType: TextInputType.phone,
          validator: (value) =>
              FormValidator.validateTextField(value, l10n.phone),
        ),
        KaziSpacings.verticalXs,
        KaziFieldInput(
          fieldKey: _identifierKey,
          label: '${l10n.document} · ${l10n.optional}',
          placeholder: l10n.documentHint,
          controller: _identifierController,
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }
}
