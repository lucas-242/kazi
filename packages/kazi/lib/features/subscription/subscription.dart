import 'package:flutter/material.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/presenter/widgets/paywall_view.dart';

export 'presenter/widgets/paywall_view.dart';

/// Presents the paywall as a full-screen page so the plan comparison and CTA are
/// never clipped. Pass [limit] to show the "limit reached" variant tailored to
/// the blocked action.
Future<void> showPaywall(BuildContext context, {LimitType? limit}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => PaywallView(limit: limit),
    ),
  );
}
