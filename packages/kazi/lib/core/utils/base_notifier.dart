import 'dart:async';

import 'package:kazi/core/routes/current_screen.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'base_state.dart';

/// Shared error handling for synchronous Riverpod notifiers whose state
/// extends [BaseState]. Mirrors the old `BaseCubit`, emitting an error status
/// with a localized message instead of calling `emit`.
mixin BaseNotifier<T extends BaseState> on $Notifier<T> {
  void onAppError(AppError error) {
    Log.error(error.message);
    _reportError(ref, error);
    state =
        state.copyWith(
              callbackMessage: error.message,
              status: BaseStateStatus.error,
            )
            as T;
  }

  void unexpectedError(Object exception) {
    Log.error(exception);
    _reportError(ref, exception);
    state =
        state.copyWith(
              callbackMessage: KaziLocalizations.current.errorUnknowError,
              status: BaseStateStatus.error,
            )
            as T;
  }
}

/// Same as [BaseNotifier] but for asynchronous notifiers whose state is wrapped
/// in an [AsyncValue]. Only updates the state when there is already resolved
/// data to copy from.
mixin BaseAsyncNotifier<T extends BaseState> on $AsyncNotifier<T> {
  void onAppError(AppError error) {
    Log.error(error.message);
    _reportError(ref, error);
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
            callbackMessage: error.message,
            status: BaseStateStatus.error,
          )
          as T,
    );
  }

  void unexpectedError(Object exception) {
    Log.error(exception);
    _reportError(ref, exception);
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
            callbackMessage: KaziLocalizations.current.errorUnknowError,
            status: BaseStateStatus.error,
          )
          as T,
    );
  }
}

/// Records that an error was put in front of the user, and feeds the friction
/// detector.
///
/// Here rather than in each controller because every controller funnels its
/// failures through these two methods, so no future one can forget to.
void _reportError(Ref ref, Object exception) {
  // Guarded as a whole: this runs on the failure path of every screen, so
  // resolving the providers — not just calling them — must be unable to turn a
  // handled error into an unhandled one.
  try {
    // The class, never the message: the message is localized, so grouping on it
    // would split one problem across three languages, and it can quote what the
    // user typed.
    final code = exception.runtimeType.toString();
    final screen = currentScreenName(() => ref.read(kaziRouterProvider));

    unawaited(
      ref
          .read(analyticsServiceProvider)
          .log(
            AnalyticsEvent.errorShown,
            parameters: {'code': code, 'screen': screen},
          ),
    );

    ref.read(frictionDetectorProvider).onError(code: code, screen: screen);
  } catch (analyticsFailure) {
    Log.error('Failed to report error to analytics: $analyticsFailure');
  }
}
