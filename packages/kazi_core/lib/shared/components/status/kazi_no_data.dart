import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/images/kazi_image.dart';
import 'package:kazi_core/shared/components/nav_bars/kazi_app_bar.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_safe_area.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziNoData extends StatelessWidget {
  const KaziNoData({
    this.fullPage = false,
    super.key,
    required this.message,
    this.navbar,
    this.title,
  }) : assert(
          !fullPage || title != null,
          'title must be provided when fullPage is true',
        );

  final String message;
  final Widget? navbar;

  final bool fullPage;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (fullPage) {
      return Scaffold(
        appBar: KaziAppBar(
          title: title!,
        ),
        body: KaziSafeArea(
          child: _NoDataContent(message: message, navbar: navbar),
        ),
      );
    }

    return _NoDataContent(message: message, navbar: navbar);
  }
}

class _NoDataContent extends StatelessWidget {
  const _NoDataContent({required this.message, this.navbar});

  final String message;
  final Widget? navbar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (navbar != null) navbar!,
          if (navbar != null) KaziSpacings.verticalMd,
          const KaziImage(KaziImageAssets.noData),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaziInsets.lg),
            child: Text(
              message,
              style: KaziTextStyles.headlineSmall.copyWith(
                color: context.colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          KaziSpacings.verticalLg,
        ],
      ),
    );
  }
}
