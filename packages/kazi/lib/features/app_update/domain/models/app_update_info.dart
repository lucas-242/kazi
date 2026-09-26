import 'package:kazi/features/app_update/domain/models/whats_new_entry.dart';

enum AppUpdateStatus { upToDate, optional, mandatory }

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.status,
    required this.latestVersion,
    required this.storeUrl,
    this.currentVersion = '',
    this.whatsNew = const [],
  });

  const AppUpdateInfo.upToDate()
    : status = AppUpdateStatus.upToDate,
      latestVersion = '',
      storeUrl = '',
      currentVersion = '',
      whatsNew = const [];

  final AppUpdateStatus status;
  final String latestVersion;
  final String storeUrl;

  /// The version installed on this device — the forced-update screen's "you're
  /// on X, this needs Y" line.
  final String currentVersion;

  /// The release announcement for [currentVersion], already resolved to the
  /// device's language. Empty whenever the console has nothing published for
  /// the version actually running — see `RemoteConfigAppUpdateService`.
  final List<WhatsNewEntry> whatsNew;

  bool get isMandatory => status == AppUpdateStatus.mandatory;
  bool get isOptional => status == AppUpdateStatus.optional;
}
