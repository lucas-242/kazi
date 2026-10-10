import 'package:equatable/equatable.dart';

enum CurrencyMigrationStatus { idle, applying, done, error }

class CurrencyMigrationState extends Equatable {
  const CurrencyMigrationState({
    this.status = CurrencyMigrationStatus.idle,
    this.errorMessage,
    this.failure,
    this.failureTrace,
  });

  final CurrencyMigrationStatus status;
  final String? errorMessage;

  /// What made the migration fail, and where it was caught — for whoever
  /// rethrows it, so the report names the root cause.
  final Object? failure;
  final StackTrace? failureTrace;

  CurrencyMigrationState copyWith({
    CurrencyMigrationStatus? status,
    String? errorMessage,
    Object? failure,
    StackTrace? failureTrace,
  }) => CurrencyMigrationState(
    status: status ?? this.status,
    errorMessage: errorMessage,
    failure: failure,
    failureTrace: failureTrace,
  );

  @override
  List<Object?> get props => [status, errorMessage, failure];
}
