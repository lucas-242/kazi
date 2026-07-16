import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi_companies/app.dart';
import 'package:kazi_companies/core/environments/environment.dart';
import 'package:kazi_companies/core/routes/routes.dart';
import 'package:kazi_core/kazi_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  final container = ProviderContainer();
  AppNavigator.init(container);

  Log.flow('Environment: ${Environment.flavor}');

  return runApp(App(container: container));
}
