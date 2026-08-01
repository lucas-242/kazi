import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/bottom_app_bar/kazi_bottom_app_button.dart';

/// An animated bottom navigation bar built from [KaziBottomAppButton] tabs.
///
/// Each tab is passed as configuration and rebuilt internally, inheriting the
/// bar-level defaults declared here whenever the tab leaves a value null.
class KaziBottomAppBar extends StatefulWidget {
  const KaziBottomAppBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTabChange,
    this.gap = 0,
    this.padding = const EdgeInsets.all(25),
    this.activeColor,
    this.color,
    this.rippleColor = Colors.transparent,
    this.hoverColor = Colors.transparent,
    this.backgroundColor = Colors.transparent,
    this.tabBackgroundColor = Colors.transparent,
    this.tabBorderRadius = 100.0,
    this.iconSize,
    this.textStyle,
    this.curve = Curves.easeInCubic,
    this.tabMargin = EdgeInsets.zero,
    this.debug = false,
    this.duration = const Duration(milliseconds: 500),
    this.tabBorder,
    this.tabActiveBorder,
    this.tabShadow,
    this.haptic = true,
    this.tabBackgroundGradient,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.style = KaziBottomAppBarStyle.google,
    this.textSize,
  });

  final List<KaziBottomAppButton> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabChange;
  final double gap;
  final double tabBorderRadius;
  final double? iconSize;
  final Color? activeColor;
  final Color backgroundColor;
  final Color tabBackgroundColor;
  final Color? color;
  final Color rippleColor;
  final Color hoverColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry tabMargin;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;
  final bool debug;
  final bool haptic;
  final Border? tabBorder;
  final Border? tabActiveBorder;
  final List<BoxShadow>? tabShadow;
  final Gradient? tabBackgroundGradient;
  final MainAxisAlignment mainAxisAlignment;
  final KaziBottomAppBarStyle? style;
  final double? textSize;

  @override
  State<KaziBottomAppBar> createState() => _KaziBottomAppBarState();
}

class _KaziBottomAppBarState extends State<KaziBottomAppBar> {
  late int selectedIndex;
  bool clickable = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(KaziBottomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        children: widget.tabs.map((t) => _buildTab(t)).toList(),
      ),
    );
  }

  KaziBottomAppButton _buildTab(KaziBottomAppButton tab) {
    final int index = widget.tabs.indexOf(tab);
    return KaziBottomAppButton(
      key: tab.key,
      icon: tab.icon,
      text: tab.text,
      active: selectedIndex == index,
      style: tab.style ?? widget.style,
      textSize: tab.textSize ?? widget.textSize,
      border: tab.border ?? widget.tabBorder,
      activeBorder: tab.activeBorder ?? widget.tabActiveBorder,
      shadow: tab.shadow ?? widget.tabShadow,
      borderRadius: tab.borderRadius ??
          BorderRadius.all(Radius.circular(widget.tabBorderRadius)),
      debug: widget.debug,
      margin: tab.margin ?? widget.tabMargin,
      gap: tab.gap ?? widget.gap,
      iconActiveColor: tab.iconActiveColor ?? widget.activeColor,
      iconColor: tab.iconColor ?? widget.color,
      iconSize: tab.iconSize ?? widget.iconSize,
      textColor: tab.textColor ?? widget.activeColor,
      textStyle: tab.textStyle ?? widget.textStyle,
      rippleColor: tab.rippleColor ?? widget.rippleColor,
      hoverColor: tab.hoverColor ?? widget.hoverColor,
      padding: tab.padding ?? widget.padding,
      leading: tab.leading,
      haptic: widget.haptic,
      curve: widget.curve,
      duration: widget.duration,
      backgroundGradient:
          tab.backgroundGradient ?? widget.tabBackgroundGradient,
      backgroundColor: tab.backgroundColor ?? widget.tabBackgroundColor,
      onPressed: () => _onTabPressed(index, tab),
    );
  }

  void _onTabPressed(int index, KaziBottomAppButton tab) {
    if (!clickable) return;
    setState(() {
      selectedIndex = index;
      clickable = false;
    });

    tab.onPressed?.call();
    widget.onTabChange?.call(selectedIndex);

    Future.delayed(widget.duration, () {
      if (context.mounted) {
        setState(() => clickable = true);
      }
    });
  }
}
