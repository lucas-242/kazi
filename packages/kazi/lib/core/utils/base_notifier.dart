import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'base_state.dart';

/// Shared error handling for synchronous Riverpod notifiers whose state
/// extends [BaseState]. Mirrors the old `BaseCubit`, emitting an error status
/// with a localized message instead of calling `emit`.
mixin BaseNotifier<T extends BaseState> on $Notifier<T> {
  void onAppError(AppError error) {
    Log.error(error.message);
    state =
        state.copyWith(
              callbackMessage: error.message,
              status: BaseStateStatus.error,
            )
            as T;
  }

  void unexpectedError(Object exception) {
    Log.error(exception);
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
