import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'setup_preview_controller.g.dart';

/// Debug only: the flow a rehearsal of the setup runs, or null for the real
/// setup. See `features/onboarding/README.md`.
@Riverpod(keepAlive: true)
class SetupPreview extends _$SetupPreview {
  @override
  SetupFlow? build() => null;

  void start(SetupFlow flow) => state = flow;

  void stop() => state = null;
}
