import 'package:equatable/equatable.dart';

enum AccountActionStatus { idle, running, error }

/// Progress of an action on the whole account — signing out or deleting it.
class AccountActionState extends Equatable {
  const AccountActionState({
    this.status = AccountActionStatus.idle,
    this.errorMessage,
  });

  final AccountActionStatus status;
  final String? errorMessage;

  bool get isRunning => status == AccountActionStatus.running;

  AccountActionState copyWith({
    AccountActionStatus? status,
    String? errorMessage,
  }) => AccountActionState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, errorMessage];
}
