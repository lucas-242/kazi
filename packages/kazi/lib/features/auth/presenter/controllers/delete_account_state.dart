import 'package:equatable/equatable.dart';

enum DeleteAccountStatus { idle, deleting, error }

class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.status = DeleteAccountStatus.idle,
    this.errorMessage,
  });

  final DeleteAccountStatus status;
  final String? errorMessage;

  bool get isDeleting => status == DeleteAccountStatus.deleting;

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    String? errorMessage,
  }) => DeleteAccountState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, errorMessage];
}
