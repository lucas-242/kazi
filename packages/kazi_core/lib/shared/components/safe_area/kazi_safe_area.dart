import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_padding_wrap.dart';
import 'package:kazi_core/shared/components/safe_area/kazi_scroll_behavior.dart';
import 'package:kazi_core/shared/themes/settings/kazi_colors.dart';

class KaziSafeArea extends StatelessWidget {
  const KaziSafeArea({
    super.key,
    this.onRefresh,
    this.child,
    this.padding,
  });

  final Future<void> Function()? onRefresh;
  final Widget? child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: KaziScrollBehavior(),
        child: onRefresh != null
            ? RefreshIndicator(
                color: KaziColors.black,
                backgroundColor: KaziColors.white,
                onRefresh: onRefresh!,
                child: KaziPaddingWrap(
                  paddingLeft: padding?.left,
                  paddingRight: padding?.right,
                  paddingTop: padding?.top,
                  paddingBottom: padding?.bottom,
                  child: child,
                ),
              )
            : KaziPaddingWrap(
                paddingLeft: padding?.left,
                paddingRight: padding?.right,
                paddingTop: padding?.top,
                paddingBottom: padding?.bottom,
                child: child,
              ),
      ),
    );
  }
}
