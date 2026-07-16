import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/settings/kazi_text_styles.dart';

class RowText extends StatelessWidget {
  const RowText({
    super.key,
    required this.leftText,
    required this.rightText,
    this.leftTextStyle,
    this.rightTextStyle,
  });
  final String leftText;
  final String rightText;
  final TextStyle? leftTextStyle;
  final TextStyle? rightTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(leftText, style: leftTextStyle ?? KaziTextStyles.titleSm),
        Text(rightText, style: rightTextStyle ?? KaziTextStyles.titleSm),
      ],
    );
  }
}
