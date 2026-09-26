import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Raised when the user cancels the purchase flow. Callers usually treat this
/// as a no-op rather than a hard error.
class PurchaseCancelledError extends ClientError {
  PurchaseCancelledError(super.message, {super.trace});
}

/// Raised when the subscription offering/package could not be loaded.
class OfferingUnavailableError extends ExternalError {
  OfferingUnavailableError(super.message, {super.trace});
}
