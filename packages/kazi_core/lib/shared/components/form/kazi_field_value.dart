import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// The value line of a [KaziField] that holds a selection rather than typing:
/// what was chosen, or the placeholder saying what to choose.
class KaziFieldValue extends StatelessWidget {
  const KaziFieldValue({
    super.key,
    required this.value,
    required this.placeholder,
    this.leading,
  });

  /// Null or empty renders [placeholder].
  final String? value;
  final String placeholder;

  /// A mark before the value — the colour dot identifying a catalog item.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = value ?? '';
    final isEmpty = text.isEmpty;

    return Row(
      children: [
        if (leading != null && !isEmpty) ...[
          leading!,
          KaziSpacings.horizontalXs,
        ],
        Flexible(
          child: Text(
            isEmpty ? placeholder : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KaziTextStyles.bodyMedium.copyWith(
              color: isEmpty ? colors.textMuted : colors.text,
              fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
