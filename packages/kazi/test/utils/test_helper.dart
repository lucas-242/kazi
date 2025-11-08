import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

abstract class TestHelper {
  static Future<void> loadAppLocalizations() async {
    await KaziLocalizations.load(const Locale.fromSubtags(languageCode: 'en'));
  }
}
