import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/app.dart';
import 'package:sterrenburg.github.flutterhole/quick_actions.dart';
import 'package:sterrenburg.github.flutterhole/screens/home_screen.dart';
import 'package:sterrenburg.github.flutterhole/screens/welcome_screen.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';

void main() async {
  quickActions();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.time.toIso8601String()}] ${record.loggerName}: ${record.level.name}: ${record.message}');
  });

  final bool firstUse = await Preference.firstUse();
  final Widget screen = firstUse ? WelcomeScreen() : HomeScreen();

  bool isDark = await PreferenceIsDark().get();
  if (isDark.runtimeType == Null) {
    await Preference.resetAll();
    isDark = await PreferenceIsDark().get();
  }

  Brightness brightness = isDark ? Brightness.dark : Brightness.light;

  runApp(AppState(child: MyApp(home: screen), brightness: brightness));
}
