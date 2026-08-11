import 'package:kazi/features/services/domain/models/service.dart';

/// Narrows the listed services by whether they have been paid.
///
/// Applied in memory over the services already fetched for the period — the
/// Firestore query stays a date-range query, so flipping this costs no read.
enum ReceiptFilter {
  all,
  pending,
  received;

  bool allows(Service service) => switch (this) {
    ReceiptFilter.all => true,
    ReceiptFilter.pending => !service.isReceived,
    ReceiptFilter.received => service.isReceived,
  };
}
