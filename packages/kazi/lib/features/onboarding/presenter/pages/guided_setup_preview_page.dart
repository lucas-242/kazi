import 'package:flutter/material.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi/features/onboarding/presenter/controllers/setup_preview_controller.dart';
import 'package:kazi/features/onboarding/presenter/pages/guided_setup_page.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Debug only: rehearses [flow] of the setup without writing anything. See
/// `features/onboarding/README.md`.
Future<void> openGuidedSetupPreview(
  BuildContext context,
  WidgetRef ref,
  SetupFlow flow,
) {
  ref.read(setupPreviewProvider.notifier).start(flow);
  // Kept alive, so it may still hold a finished real run.
  ref.invalidate(guidedSetupControllerProvider);

  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(builder: (_) => const _GuidedSetupPreviewPage()),
  );
}

class _GuidedSetupPreviewPage extends StatefulWidget {
  const _GuidedSetupPreviewPage();

  @override
  State<_GuidedSetupPreviewPage> createState() =>
      _GuidedSetupPreviewPageState();
}

class _GuidedSetupPreviewPageState extends State<_GuidedSetupPreviewPage> {
  ProviderContainer? _container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  /// The rehearsal's state must not outlive it: the controller is kept alive,
  /// and a real setup opened later would otherwise resume the preview.
  @override
  void dispose() {
    final container = _container;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      container?.read(setupPreviewProvider.notifier).stop();
      container?.invalidate(guidedSetupControllerProvider);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const GuidedSetupPage();
}
