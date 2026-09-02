import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A price rendered as something you can obviously edit.
///
/// The dashed amber underline is the most widely read "this is a field" signal
/// there is, and it beats a small pencil in the corner. Without it a good share
/// of people read the number as the app's, accept a wrong value, and then
/// distrust every total that follows from it.
class SetupEditablePrice extends StatelessWidget {
  const SetupEditablePrice({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KaziInsets.xxs,
            vertical: KaziInsets.xxs,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.brand.text, width: 1.5),
            ),
          ),
          child: Text(
            label,
            style: KaziTextStyles.bodyMedium.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
