import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// "· recebido" — the word marking a service as already paid for, appended to
/// the line it belongs to rather than replacing anything on the row.
///
/// A `TextSpan` and not a widget so it ellipsises together with that line: the
/// situation is the first thing to give way when the client's name is long, and
/// the row's amounts keep their column either way. See README.md.
TextSpan receivedMarkSpan(BuildContext context) {
  return TextSpan(
    text: ' · ${KaziLocalizations.current.received.toLowerCase()}',
    style: KaziTextStyles.labelSmall.copyWith(
      color: context.colors.success.onSurface,
      fontWeight: FontWeight.w600,
    ),
  );
}
