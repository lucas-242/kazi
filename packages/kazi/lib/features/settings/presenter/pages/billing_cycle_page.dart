import 'package:flutter/material.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/features/settings/presenter/widgets/billing_cycle_editor.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Lets the user say when they actually get paid.
///
/// A full page rather than a bottom sheet: the anchor picker is itself a sheet,
/// and stacking one on another is where this stops behaving on small screens.
class BillingCyclePage extends ConsumerStatefulWidget {
  const BillingCyclePage({super.key});

  @override
  ConsumerState<BillingCyclePage> createState() => _BillingCyclePageState();
}

class _BillingCyclePageState extends ConsumerState<BillingCyclePage> {
  /// Seeded from the stored cycle, then edited locally so the preview can
  /// update on every tap without a write per keystroke.
  late final BillingCycle _initial;
  BillingCycle? _draft;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initial = ref.read(billingCycleProvider);
    _draft = _initial;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final draft = _draft;

    return Scaffold(
      appBar: KaziAppBar(title: l10n.billingCycle),
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.billingCycleDescription,
              style: KaziTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                height: 24 / 15,
                color: context.colors.textMuted,
              ),
            ),
            KaziSpacings.verticalLg,
            BillingCycleEditor(
              initial: _initial,
              onChanged: (cycle) => setState(() => _draft = cycle),
            ),
            KaziSpacings.verticalLg,
          ],
        ),
      ),
      bottomNavigationBar: KaziFormFooter(
        label: l10n.billingCycleSave,
        onTap: _isSaving || draft == null ? null : () => _onSave(draft),
      ),
    );
  }

  Future<void> _onSave(BillingCycle draft) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(billingCycleControllerProvider.notifier).select(draft);
      if (mounted) KaziNavigator.pop();
    } on AppError catch (exception) {
      if (mounted) KaziSnackbar.show(context, exception.message);
    } catch (_) {
      if (mounted) {
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
