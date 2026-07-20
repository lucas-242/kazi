enum AppUpdateStatus { upToDate, optional, mandatory }

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.status,
    required this.latestVersion,
    required this.storeUrl,
  });

  const AppUpdateInfo.upToDate()
    : status = AppUpdateStatus.upToDate,
      latestVersion = '',
      storeUrl = '';

  final AppUpdateStatus status;
  final String latestVersion;
  final String storeUrl;

  bool get isMandatory => status == AppUpdateStatus.mandatory;
  bool get isOptional => status == AppUpdateStatus.optional;
}
