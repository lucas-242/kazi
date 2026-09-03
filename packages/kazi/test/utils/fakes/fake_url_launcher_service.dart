import 'package:kazi_core/kazi_core.dart';

/// Records every URL a flow tried to open, instead of reaching the platform.
class FakeUrlLauncherService implements KaziUrlLauncherService {
  FakeUrlLauncherService({this.succeeds = true});

  /// What [launch] returns for every call — flips to test the failure
  /// snackbar without a second fake.
  final bool succeeds;

  final List<String> opened = [];

  @override
  Future<bool> launch(String url) async {
    opened.add(url);
    return succeeds;
  }
}
