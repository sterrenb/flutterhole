import 'package:flutter/material.dart';
import 'package:flutter_hole/app.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:flutter_hole/models/preferences/preference_is_dark.dart';
import 'package:flutter_hole/quick_actions.dart';

void main() async {
  quickActions();
  bool isDark = await PreferenceIsDark().get();
  if (isDark.runtimeType == Null) {
    await Preference.clearAll();
    isDark = await PreferenceIsDark().get();
  }

  runApp(AppState(
      child: MyApp(), brightness: isDark ? Brightness.dark : Brightness.light));
}
