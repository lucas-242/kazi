import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Leaves a finished setup. A debug preview was pushed over the menu, so it
/// returns there instead of going home.
void leaveSetup(BuildContext context, GuidedSetupState state) {
  if (state.isPreview) {
    Navigator.of(context).pop();
  } else {
    KaziNavigator.navigate(AppPage.home);
  }
}
