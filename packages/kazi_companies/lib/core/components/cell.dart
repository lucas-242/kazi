import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class Cell extends StatelessWidget {
  const Cell({
    super.key,
    this.text,
    this.child,
    this.isHeader = false,
  }) : assert(text != null || child != null);

  final String? text;
  final Widget? child;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          top: KaziInsets.sm,
          bottom: KaziInsets.sm,
          right: KaziInsets.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (text != null)
              Text(
                text!,
                style: isHeader ? KaziTextStyles.titleSmall : KaziTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
