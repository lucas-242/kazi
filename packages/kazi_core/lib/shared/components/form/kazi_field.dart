import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// The app's field shape: an outlined card that carries its own caption.
///
/// The caption lives **inside** the box, above the value, instead of floating
/// away as a placeholder. A form of six answered fields would otherwise be six
/// unlabelled values, and the one thing someone re-reads before saving is what
/// each number was for.
///
/// **The box is the only thing outlined.** The control inside it draws no
/// border of its own — a frame inside a frame reads as two controls, and the
/// caption already says where the field starts. The box's own outline is what
/// carries state: the focus ring while it is being typed in, danger while it
/// is refusing to be left alone.
///
/// It holds a value line, not an input: [KaziFieldInput] puts a text field in
/// it, [KaziFieldPicker] puts a selection in it, and anything else can pass its
/// own [child].
class KaziField extends StatelessWidget {
  const KaziField({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
    this.onTap,
    this.isFocused = false,
    this.errorText,
    this.semanticLabel,
  });

  /// Upper-cased by this widget — [KaziTextStyles.tag] is the one style the
  /// brandbook allows upper case on, and Flutter has no text transform.
  final String label;

  /// The value line, under the caption.
  final Widget child;

  /// Sits at the end of the value line: the "+ Novo" pill that creates what
  /// the picker could not offer. It carries its own tap target, so it is not
  /// swallowed by [onTap].
  final Widget? trailing;

  final VoidCallback? onTap;

  /// Draws the focus ring. Set by the field's own input; a box on its own has
  /// nothing to focus.
  final bool isFocused;

  /// Rendered under the box, and tints its outline. Never inside it — an error that
  /// grows the box shifts every field below it.
  final String? errorText;

  final String? semanticLabel;

  /// Tall enough that the caption and the value each get their own line
  /// without the box closing in on them. A field is where the person spends
  /// the whole screen, so it is the last place to save vertical space.
  static const double _minHeight = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;

    final Color borderColor = hasError
        ? colors.danger.fill
        : isFocused
            ? colors.focusRing
            : colors.border;

    return Semantics(
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: colors.card,
            borderRadius: KaziRadii.mdBorder,
            child: InkWell(
              onTap: onTap,
              borderRadius: KaziRadii.mdBorder,
              child: Container(
                constraints: const BoxConstraints(minHeight: _minHeight),
                padding: const EdgeInsets.symmetric(
                  horizontal: KaziInsets.md,
                  vertical: KaziInsets.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: KaziRadii.mdBorder,
                  border: Border.all(
                    color: borderColor,
                    width: hasError || isFocused ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KaziFieldCaption(label),
                          KaziSpacings.verticalXxs,
                          child,
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      KaziSpacings.horizontalXs,
                      trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(
                top: KaziInsets.xxs,
                left: KaziInsets.xxs,
              ),
              child: Text(
                errorText!,
                style: KaziTextStyles.labelSmall.copyWith(
                  color: colors.danger.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
