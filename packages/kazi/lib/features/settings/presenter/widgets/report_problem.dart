import 'package:flutter/material.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Hands the support address to the device's mail app, with the subject and
/// the opening line already written — the report only has to be finished.
///
/// The body names who is writing (name, email and uid) because a report that
/// cannot be tied to an account cannot be answered.
Future<void> openProblemReport(BuildContext context, WidgetRef ref) async {
  final l10n = KaziLocalizations.current;
  final user = ref.read(authServiceProvider).user;

  final body = l10n.reportProblemBody(
    user?.name ?? '',
    user?.email ?? '',
    user?.uid ?? '',
  );

  // Built by hand rather than with `Uri(queryParameters:)`, which encodes a
  // space as `+` — mail apps show that literally in the subject line.
  final url =
      'mailto:${l10n.contactEmail}'
      '?subject=${Uri.encodeComponent(l10n.reportProblemSubject)}'
      '&body=${Uri.encodeComponent(body)}';

  final launched = await ref.read(kaziUrlLauncherServiceProvider).launch(url);
  if (!launched && context.mounted) {
    KaziSnackbar.show(context, l10n.errorToOpenApp);
  }
}
