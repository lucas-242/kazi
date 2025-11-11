import 'package:flutter/material.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/widgets/buttons/circular_button/circular_button.dart';
import 'package:kazi_core/kazi_core.dart';

import 'pill_button.dart';

class BackAndPill extends StatelessWidget {
  const BackAndPill({
    super.key,
    this.pillText,
    this.onTapPill,
    this.text,
    this.foregroundColor,
    this.backgroundColor,
    this.onTapBack,
  });
  final VoidCallback? onTapBack;
  final VoidCallback? onTapPill;
  final String? text;
  final String? pillText;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircularButton(
              onTap: () => onTapBack != null ? onTapBack!() : context.back(),
              child: const Icon(Icons.chevron_left),
            ),
            KaziSpacings.horizontalXs,
            Visibility(
              visible: text != null,
              child: Text(text ?? '', style: KaziTextStyles.titleMd),
            ),
          ],
        ),
        Visibility(
          visible: pillText != null && pillText!.isNotEmpty,
          child: PillButton(
            onTap: onTapPill,
            backgroundColor: backgroundColor ?? KaziColors.black,
            foregroundColor: foregroundColor ?? KaziColors.white,
            child: Text(pillText ?? ''),
          ),
        ),
      ],
    );
  }
}
