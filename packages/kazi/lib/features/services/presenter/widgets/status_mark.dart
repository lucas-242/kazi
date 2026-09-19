import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_status.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// "· recebido", "· cancelado" — the word saying where a service stands,
/// appended to the line it belongs to rather than replacing anything on the
/// row. Null for a pending service, which is the ordinary case and has nothing
/// to announce. The separator is dropped when [precededBy] is empty, so the
/// line never opens with a dangling "·".
///
/// A `TextSpan` and not a widget so it ellipsises together with that line: the
/// situation is the first thing to give way when the client's name is long, and
/// the row's amounts keep their column either way. See README.md.
TextSpan? statusMarkSpan(
  BuildContext context,
  Service service, {
  required String precededBy,
}) {
  final colors = context.colors;
  final (String text, Color color) = switch (service.status) {
    ServiceStatus.pending => ('', colors.textMuted),
    ServiceStatus.received => (
      KaziLocalizations.current.received,
      colors.success.onSurface,
    ),
    ServiceStatus.cancelled => (
      KaziLocalizations.current.statusCancelled,
      colors.danger.onSurface,
    ),
  };
  if (text.isEmpty) return null;

  // The separator carries no style of its own, so it keeps the line's colour;
  // only the word is coloured.
  return TextSpan(
    text: precededBy.isEmpty ? null : ' · ',
    children: [
      TextSpan(
        text: text.toLowerCase(),
        style: KaziTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
