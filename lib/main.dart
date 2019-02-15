import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/app.dart';
import 'package:sterrenburg.github.flutterhole/models/app_state.dart';
import 'package:sterrenburg.github.flutterhole/models/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/models/preferences/preference_is_dark.dart';
import 'package:sterrenburg.github.flutterhole/quick_actions.dart';

void main() async {
  quickActions();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.time.toIso8601String()}] ${record.loggerName}: ${record.level.name}: ${record.message}');
  });

  bool isDark = await PreferenceIsDark().get();
  if (isDark.runtimeType == Null) {
    await Preference.clearAll();
    isDark = await PreferenceIsDark().get();
  }

  runApp(AppState(
      child: MyApp(), brightness: isDark ? Brightness.dark : Brightness.light));
}
