import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

enum CurrencyMigrationStatus { idle, required, applying, done, error }

class CurrencyMigrationState extends Equatable {
  const CurrencyMigrationState({
    this.status = CurrencyMigrationStatus.idle,
    this.suggestedCurrency = SupportedCurrency.usd,
    this.affectedServices = 0,
    this.errorMessage,
  });

  final CurrencyMigrationStatus status;

  /// Preselected in the picker — the device's country guess, so the common case
  /// is a single tap.
  final SupportedCurrency suggestedCurrency;

  /// Services the choice will be applied to, shown so the user understands the
  /// weight of the answer.
  final int affectedServices;

  final String? errorMessage;

  /// Drives the router gate.
  bool get isRequired =>
      status == CurrencyMigrationStatus.required ||
      status == CurrencyMigrationStatus.applying ||
      status == CurrencyMigrationStatus.error;

  bool get isApplying => status == CurrencyMigrationStatus.applying;

  CurrencyMigrationState copyWith({
    CurrencyMigrationStatus? status,
    SupportedCurrency? suggestedCurrency,
    int? affectedServices,
    String? errorMessage,
  }) {
    return CurrencyMigrationState(
      status: status ?? this.status,
      suggestedCurrency: suggestedCurrency ?? this.suggestedCurrency,
      affectedServices: affectedServices ?? this.affectedServices,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    suggestedCurrency,
    affectedServices,
    errorMessage,
  ];
}
