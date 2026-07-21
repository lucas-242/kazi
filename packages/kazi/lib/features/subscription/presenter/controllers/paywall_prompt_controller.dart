import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'paywall_prompt_controller.g.dart';

/// App-wide signal used to request the paywall when a freemium limit is hit.
/// Creation controllers call [promptFor]; a single listener at the app shell
/// presents the paywall and then calls [dismiss] so the same limit can trigger
/// it again next time.
@Riverpod(keepAlive: true)
class PaywallPromptController extends _$PaywallPromptController {
  @override
  LimitType? build() => null;

  void promptFor(LimitType limit) => state = limit;

  void dismiss() => state = null;
}
