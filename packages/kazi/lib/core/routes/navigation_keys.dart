import 'package:flutter/widgets.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// One navigator per bottom-navigation branch, so each tab keeps its own stack
/// and scroll position while the others stay alive behind it.
final homeBranchKey = GlobalKey<NavigatorState>();
final servicesBranchKey = GlobalKey<NavigatorState>();
final clientsBranchKey = GlobalKey<NavigatorState>();
final menuBranchKey = GlobalKey<NavigatorState>();
