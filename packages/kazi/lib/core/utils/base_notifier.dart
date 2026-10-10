import 'package:kazi/core/utils/shown_error_reporter.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'base_state.dart';

/// Shared error handling for synchronous Riverpod notifiers whose state
/// extends [BaseState]. Mirrors the old `BaseCubit`, emitting an error status
/// with a localized message instead of calling `emit`.
mixin BaseNotifier<T extends BaseState> on $Notifier<T> {
  final _inFlight = InFlight();

  /// Runs [action] unless the same [key] is still running. Every write a user
  /// can tap goes through here; see [InFlight].
  Future<R?> runOnce<R>(Object key, Future<R> Function() action) =>
      _inFlight.run(key, action);

  void onAppError(AppError error, [StackTrace? trace]) {
    Log.error(error.message);
    reportShownError(ref.read, error, trace, origin: '$runtimeType');
    state =
        state.copyWith(
              callbackMessage: error.message,
              status: BaseStateStatus.error,
            )
            as T;
  }

  void unexpectedError(Object exception, [StackTrace? trace]) {
    Log.error(exception);
    reportShownError(ref.read, exception, trace, origin: '$runtimeType');
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
  final _inFlight = InFlight();

  /// Runs [action] unless the same [key] is still running. Every write a user
  /// can tap goes through here; see [InFlight].
  Future<R?> runOnce<R>(Object key, Future<R> Function() action) =>
      _inFlight.run(key, action);

  void onAppError(AppError error, [StackTrace? trace]) {
    Log.error(error.message);
    reportShownError(ref.read, error, trace, origin: '$runtimeType');
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

  void unexpectedError(Object exception, [StackTrace? trace]) {
    Log.error(exception);
    reportShownError(ref.read, exception, trace, origin: '$runtimeType');
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
