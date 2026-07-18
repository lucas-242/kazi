import 'package:flutter/material.dart';
import 'package:kazi/core/routes/navigation_keys.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/pages/client_details_page.dart';
import 'package:kazi/features/clients/presenter/pages/client_form_page.dart';
import 'package:kazi/features/clients/presenter/pages/clients_page.dart';
import 'package:kazi_core/kazi_core.dart';

export 'presenter/pages/client_details_page.dart';
export 'presenter/pages/client_form_page.dart';
export 'presenter/pages/clients_page.dart';

final class ClientArguments extends KaziNavigationArguments {
  const ClientArguments({super.previousPage, this.client});

  final ClientEntry? client;
}

abstract final class ClientsRoutes {
  // Full-screen sub-routes render on the root navigator (above AppShell), so
  // they hide the bottom navigation and rely on their own back navbar.
  static final GoRoute addClient = GoRoute(
    path: 'add-client',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => Scaffold(
      body: ClientFormPage(
        client: (state.extra as ClientArguments?)?.client,
      ),
    ),
  );

  static final GoRoute clientDetails = GoRoute(
    path: 'client-details',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => Scaffold(
      body: ClientDetailsPage(
        clientId: (state.extra as ClientArguments).client!.id,
      ),
    ),
  );

  // Nested under the profile shell route (`/profile`), so the list keeps the
  // bottom navigation. Matches `AppPage.clients` (`/profile/clients`).
  static GoRoute route() => GoRoute(
    path: 'clients',
    builder: (_, _) => const ClientsPage(),
    routes: [clientDetails, addClient],
  );
}
