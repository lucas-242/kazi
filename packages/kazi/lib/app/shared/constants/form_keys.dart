abstract class FormKeys {
  /// Calendar start date
  static DateTime formStartDate = DateTime(2020);

  /// Calendar end date
  static DateTime get formEndDate {
    final today = DateTime.now();
    return today.copyWith(month: today.month + 3);
  }
}
