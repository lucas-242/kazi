import 'package:bloc/bloc.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

import 'base_state.dart';

mixin BaseCubit<T extends BaseState> on Cubit<T> {
  void onAppError(AppError error) {
    Log.error(error.message);
    emit(
      state.copyWith(
            callbackMessage: error.message,
            status: BaseStateStatus.error,
          )
          as T,
    );
  }

  void unexpectedError(Object exception) {
    Log.error(exception);
    emit(
      state.copyWith(
            callbackMessage: KaziLocalizations.current.errorUnknowError,
            status: BaseStateStatus.error,
          )
          as T,
    );
  }
}
