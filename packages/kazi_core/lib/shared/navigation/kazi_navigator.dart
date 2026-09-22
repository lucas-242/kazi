import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// Calls the sheet's builder once per change to what the builder itself reads,
/// not once per rebuild of the route: the modal route rebuilds its page on
/// every frame the keyboard animates, which rebuilt every field in the sheet.
class _SheetContent extends StatefulWidget {
  const _SheetContent({required this.builder, required this.maxHeightFactor});

  final WidgetBuilder builder;
  final double? maxHeightFactor;

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  Widget? _content;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _content = null;
  }

  /// The cap is measured against the screen, then given the keyboard back:
  /// what it exists to protect is the strip of background above the sheet, and
  /// a form padded clear of an open keyboard has already stopped reaching for
  /// that strip. Applied here rather than as the route's `constraints`, which
  /// are read once and so cannot see the keyboard arrive.
  BoxConstraints get _constraints {
    final factor = widget.maxHeightFactor;
    if (factor == null) return const BoxConstraints();

    return BoxConstraints(
      maxHeight:
          context.height * factor + MediaQuery.viewInsetsOf(context).bottom,
    );
  }

  @override
  Widget build(BuildContext context) => _content ??= ConstrainedBox(
        constraints: _constraints,
        child: SafeArea(
          top: false,
          // Every sheet in the app gets this gap once, here, rather than each
          // one reinventing its own top padding — the drag handle alone reads
          // as too tight against whatever a sheet puts right under it.
          child: Padding(
            padding: const EdgeInsets.only(top: KaziInsets.sm),
            child: widget.builder(context),
          ),
        ),
      );
}

/// Abstract base class for app navigation.
/// Each app should extend this and implement the abstract methods.
abstract class KaziNavigator {
  static const double _defaultSheetMaxHeightFactor = 0.8;

  static GoRouter? _router;
  static KaziPage? Function(String route)? _pageResolver;

  static String _previousRoute = '/';
  static String _currentRoute = '/';

  static KaziPage? get previousPage => _pageResolver?.call(_previousRoute);
  static KaziPage? get currentPage => _pageResolver?.call(_currentRoute);

  static BuildContext? get context =>
      _router?.routerDelegate.navigatorKey.currentContext;

  static GoRouter get router {
    if (_router == null) {
      throw StateError(
        'KaziNavigator not initialized. Call KaziNavigator.init() first.',
      );
    }
    return _router!;
  }

  /// Initialize the navigator with the app's router configuration.
  ///
  /// [pageResolver] maps a route string to the app's [KaziPage] (usually the
  /// enum's `fromRoute`), enabling [currentPage]/[previousPage].
  static void init(
    GoRouter router, {
    KaziPage? Function(String route)? pageResolver,
  }) {
    _router = router;
    _pageResolver = pageResolver;
    _currentRoute = router.routerDelegate.currentConfiguration.uri.toString();
  }

  /// Navigate to a route without pushing to the stack
  static void navigate(KaziPage page, {Object? extra}) {
    final route = page.route;
    _setRoutes(route);
    Log.navigation('Navigating to $route');
    _router?.go(route, extra: extra);
  }

  /// Push a route onto the navigation stack
  static Future<T?> push<T>(KaziPage page, {Object? extra}) {
    final route = page.route;
    _setRoutes(route);
    Log.navigation('Pushing to $route');
    return _router!.push<T>(route, extra: extra);
  }

  /// Pop the current route
  static void pop<T>([T? result]) {
    if (!_router!.canPop()) {
      Log.navigation('Cannot pop - at root');
      return;
    }
    _setRoutes(_previousRoute);
    Log.navigation('Popping route');
    _router!.pop(result);
  }

  /// Show a dialog
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
  }) {
    Log.navigation('Showing dialog');
    return material.showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
    );
  }

  /// Shows a modal bottom sheet — every sheet in the apps opens through here.
  ///
  /// Keeps the content clear of the system navigation bar, which Flutter's
  /// sheet is drawn behind and never pads. A null [backgroundColor] takes the
  /// theme's.
  ///
  /// [maxHeightFactor] caps the sheet at that share of the screen height. A
  /// scroll-controlled sheet with enough content otherwise grows to the top
  /// edge, leaving nothing to tap or drag it away by. Null lifts the cap, for
  /// a sheet that is meant to take the whole screen.
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    Color? backgroundColor,
    double? maxHeightFactor = _defaultSheetMaxHeightFactor,
  }) {
    Log.navigation('Showing bottom sheet');
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) => _SheetContent(
        builder: builder,
        maxHeightFactor: maxHeightFactor,
      ),
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor,
    );
  }

  /// Show a snackbar
  static void showSnackbar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
    bool rootNavigator = false,
  }) {
    Log.navigation('Showing snackbar: $message');
    KaziSnackbar.show(
      context,
      message,
      duration: duration.inSeconds,
      rootNavigator: rootNavigator,
    );
  }

  static void _setRoutes(String route) {
    _previousRoute = _currentRoute;
    _currentRoute = route;
  }
}
