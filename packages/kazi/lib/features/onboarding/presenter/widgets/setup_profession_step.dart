import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/domain/models/profession_preset.dart';
import 'package:kazi/features/onboarding/domain/preset_catalog.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_option_tile.dart';
import 'package:kazi/features/onboarding/presenter/widgets/setup_scaffold.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Screen 1 — the profession, which is what picks the presets.
///
/// Nothing is typed here: three chips and a way out to typing. The kit chosen
/// is the difference between a working app and an empty one, so it is asked
/// first and answered with a tap.
class SetupProfessionStep extends ConsumerStatefulWidget {
  const SetupProfessionStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  ConsumerState<SetupProfessionStep> createState() =>
      _SetupProfessionStepState();
}

class _SetupProfessionStepState extends ConsumerState<SetupProfessionStep> {
  ProfessionPreset? _selected;
  bool _typing = false;

  GuidedSetupController get _controller =>
      ref.read(guidedSetupControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    if (_typing) {
      return _TypedProfession(
        onPicked: (preset) => _controller.chooseProfession(preset),
        onTyped: (typed) => _controller.chooseCustomProfession(typed),
        onBack: () => setState(() => _typing = false),
      );
    }

    final l10n = KaziLocalizations.current;

    return SetupScaffold(
      step: SetupStep.profession,
      showProgress: false,
      backgroundColor: context.colors.brand.fill,
      foregroundColor: context.colors.brand.onFill,
      title: l10n.setupProfessionTitle,
      subtitle: l10n.setupProfessionSubtitle,
      action: KaziElevatedButton.label(
        label: l10n.setupContinue,
        onTap: _selected == null
            ? null
            : () => _controller.chooseProfession(_selected!),
      ),
      child: Column(
        children: [
          for (final preset in PresetCatalog.featured)
            SetupOptionTile(
              label: preset.label(),
              selected: _selected == preset,
              onTap: () => setState(() => _selected = preset),
            ),
          SetupOptionTile(
            label: l10n.presetOther,
            showCheckbox: false,
            onTap: () => setState(() => _typing = true),
          ),
        ],
      ),
    );
  }
}

/// The typed path. Searching first, because "unhas", "depilação" or "tattoo"
/// usually land in a kit that already exists — and a kit is worth far more
/// than a blank form.
class _TypedProfession extends StatefulWidget {
  const _TypedProfession({
    required this.onPicked,
    required this.onTyped,
    required this.onBack,
  });

  final ValueChanged<ProfessionPreset> onPicked;
  final ValueChanged<String> onTyped;
  final VoidCallback onBack;

  @override
  State<_TypedProfession> createState() => _TypedProfessionState();
}

class _TypedProfessionState extends State<_TypedProfession> {
  final _controller = TextEditingController();
  List<ProfessionPreset> _matches = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) =>
      setState(() => _matches = PresetCatalog.search(value));

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return SetupScaffold(
      step: SetupStep.profession,
      onClose: widget.onBack,
      title: l10n.setupProfessionTypedTitle,
      subtitle: l10n.setupProfessionTypedSubtitle,
      action: KaziElevatedButton.label(
        label: l10n.setupContinue,
        onTap: _controller.text.trim().isEmpty
            ? null
            : () => widget.onTyped(_controller.text),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaziTextFormField(
            controller: _controller,
            labelText: l10n.setupProfessionField,
            autofocus: true,
            onChanged: _onChanged,
          ),
          KaziSpacings.verticalMd,
          for (final preset in _matches)
            SetupOptionTile(
              label: preset.label(),
              showCheckbox: false,
              onTap: () => widget.onPicked(preset),
            ),
          if (_controller.text.trim().isNotEmpty && _matches.isEmpty) ...[
            KaziSpacings.verticalXs,
            Text(
              l10n.setupProfessionNoMatch,
              style: KaziTextStyles.bodySmall.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The employment question, shown when no kit matched.
///
/// It sets the default commission without ever saying "commission" — the word
/// is the single most confusing thing in the setup for self-employed people,
/// many of whom genuinely do not know what to answer.
class SetupEmploymentStep extends ConsumerWidget {
  const SetupEmploymentStep({super.key, required this.state});

  final GuidedSetupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;
    final controller = ref.read(guidedSetupControllerProvider.notifier);

    return SetupScaffold(
      step: SetupStep.profession,
      title: l10n.setupUnknownProfessionTitle,
      subtitle: l10n.setupUnknownProfessionSubtitle,
      action: KaziElevatedButton.label(
        label: l10n.setupContinue,
        onTap: () => controller.goToStep(SetupStep.catalog),
      ),
      child: Column(
        children: [
          SetupOptionTile(
            label: l10n.setupSelfEmployed,
            detail: l10n.setupSelfEmployedDetail,
            selected: state.isSelfEmployed,
            onTap: () => controller.setSelfEmployed(isSelfEmployed: true),
          ),
          SetupOptionTile(
            label: l10n.setupEmployed,
            detail: l10n.setupEmployedDetail,
            selected: !state.isSelfEmployed,
            onTap: () => controller.setSelfEmployed(isSelfEmployed: false),
          ),
        ],
      ),
    );
  }
}
