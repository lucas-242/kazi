import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A search or a filter that matched nothing — data missing from *this* cut,
/// not from the account.
///
/// It hands control back rather than inviting: it repeats what was looked for
/// and offers the way out, whether that is creating the thing under the name
/// typed or clearing the filters. It carries **no** brand block — that belongs
/// to `KaziEmpty`, and here it would read as an account with nothing in it.
class KaziNoResults extends StatelessWidget {
  const KaziNoResults({
    super.key,
    required this.message,
    this.description,
    this.action,
    this.scrollable = false,
  });

  /// The headline, with the term quoted back: `Nada encontrado para "gel"`.
  final String message;

  /// What was searched, in one sentence. Optional.
  final String? description;

  /// The way out: create what was looked for, or clear the filters.
  final Widget? action;

  /// See `KaziEmpty.scrollable` — same reason, same requirement.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KaziInsets.lg,
          vertical: KaziInsets.xLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: KaziInsets.sm,
          children: [
            Text(
              message,
              style: KaziTextStyles.titleSmall.copyWith(color: colors.text),
              textAlign: TextAlign.center,
            ),
            if (description case final String text)
              Text(
                text,
                style: KaziTextStyles.bodyMedium.copyWith(
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            if (action case final Widget button) ...[
              KaziSpacings.verticalXs,
              button,
            ],
          ],
        ),
      ),
    );

    if (!scrollable) return content;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(hasScrollBody: false, child: content),
      ],
    );
  }
}
