import 'package:equatable/equatable.dart';

enum CurrencyMigrationStatus { idle, applying, done, error }

class CurrencyMigrationState extends Equatable {
  const CurrencyMigrationState({
    this.status = CurrencyMigrationStatus.idle,
    this.errorMessage,
  });

  final CurrencyMigrationStatus status;
  final String? errorMessage;

  CurrencyMigrationState copyWith({
    CurrencyMigrationStatus? status,
    String? errorMessage,
  }) => CurrencyMigrationState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, errorMessage];
}
