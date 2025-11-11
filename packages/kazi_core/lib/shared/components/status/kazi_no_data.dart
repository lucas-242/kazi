import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziNoData extends StatelessWidget {
  const KaziNoData({
    super.key,
    required this.message,
    this.navbar,
  });
  final String message;
  final Widget? navbar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (navbar != null) navbar!,
          if (navbar != null) KaziSpacings.verticalMd,
          Image.asset(KaziImageAssets.noData, package: 'kazi_core'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaziInsets.lg),
            child: Text(
              message,
              style: KaziTextStyles.headlineSm.copyWith(color: KaziColors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          KaziSpacings.verticalLg,
        ],
      ),
    );
  }
}
