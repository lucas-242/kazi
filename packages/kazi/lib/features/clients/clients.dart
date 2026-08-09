import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
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
  static final GoRoute addClient = GoRoute(
    path: 'add-client',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => Scaffold(
      body: ClientFormPage(client: (state.extra as ClientArguments?)?.client),
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

  static GoRoute shellRoute() => GoRoute(
    path: AppPage.clients.route,
    builder: (_, _) => const ClientsPage(),
    routes: [clientDetails, addClient],
  );
}
