import 'package:flutter/material.dart';

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
        Text(
          leftText,
          style: leftTextStyle ?? Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          rightText,
          style: rightTextStyle ?? Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
