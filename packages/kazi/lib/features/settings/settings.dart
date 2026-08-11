import 'package:flutter/foundation.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/features/settings/presenter/pages/billing_cycle_page.dart';
import 'package:kazi/features/settings/presenter/pages/currency_migration_page.dart';
import 'package:kazi/features/settings/presenter/pages/settings_page.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi_core/kazi_core.dart';

export 'presenter/controllers/billing_cycle_controller.dart';
export 'presenter/controllers/currency_migration_controller.dart';
export 'presenter/controllers/currency_migration_state.dart';

abstract final class SettingsRoutes {
  /// The catalogue hangs off the menu — see `ServicesRoutes.servicesType`.
  static GoRoute shellRoute() => GoRoute(
    path: AppPage.settings.route,
    builder: (_, _) => const SettingsPage(),
    routes: [
      ServicesRoutes.servicesType,
      GoRoute(
        path: 'billing-cycle',
        builder: (_, _) => const BillingCyclePage(),
      ),
      // Debug only: the token gallery is a development tool, not a feature.
      // Registering it conditionally keeps it out of release builds entirely
      // rather than merely hiding its entry point.
      if (kDebugMode)
        GoRoute(
          path: 'design-tokens',
          builder: (_, _) => const KaziThemeGalleryPage(),
        ),
    ],
  );

  /// Outside the shell: the migration gate must render without the bottom bar
  /// so there is nowhere to navigate away to.
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppPage.currencyMigration.route,
      builder: (_, _) => const CurrencyMigrationPage(),
    ),
  ];
}
