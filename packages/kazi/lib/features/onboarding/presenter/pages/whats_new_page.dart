import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// One screen, three lines, one button.
///
/// It exists so the change is announced by us rather than discovered by
/// accident in the middle of a job. Deliberately not a carousel and not a
/// sequence: nobody opened the app to read a changelog.
class WhatsNewPage extends StatelessWidget {
  const WhatsNewPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KaziInsets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaziSpacings.verticalXxLg,
              Text(l10n.whatsNewTitle, style: KaziTextStyles.headlineSmall),
              KaziSpacings.verticalLg,
              const _Line(index: 0),
              const _Line(index: 1),
              const _Line(index: 2),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: KaziElevatedButton.label(
                  label: l10n.setupResultCta,
                  onTap: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final text = switch (index) {
      0 => l10n.whatsNewCycle,
      1 => l10n.whatsNewSummary,
      _ => l10n.whatsNewCatalog,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: KaziInsets.xxs + 2),
            decoration: BoxDecoration(
              color: context.colors.category(index),
              shape: BoxShape.circle,
            ),
          ),
          KaziSpacings.horizontalXs,
          Expanded(child: Text(text, style: KaziTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
