import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/status/kazi_loading.dart';

/// Shows the [KaziLoading] in the root overlay while [isLoading] is true.
class KaziBlockingLoading extends StatefulWidget {
  const KaziBlockingLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
  });

  final bool isLoading;
  final Widget child;
  final Color? color;

  @override
  State<KaziBlockingLoading> createState() => _KaziBlockingLoadingState();
}

class _KaziBlockingLoadingState extends State<KaziBlockingLoading> {
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _controller.show();
  }

  @override
  Widget build(BuildContext context) {
    // A page that keep mounted behind another route (the shell, for example)
    // cannot block the route that is on top of it.
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final showLoading = widget.isLoading && isCurrentRoute;

    return OverlayPortal(
      controller: _controller,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (_) => showLoading
          ? Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: KaziLoading.overlay(color: widget.color),
              ),
            )
          : const SizedBox.shrink(),
      child: widget.child,
    );
  }
}
