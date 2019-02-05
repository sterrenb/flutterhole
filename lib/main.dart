import 'package:flutter/material.dart';
import 'package:flutter_hole/app.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Brightness brightness;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  brightness =
  (prefs.getBool("isDark") ?? false) ? Brightness.dark : Brightness.light;
  quickActions();
  runApp(AppState(child: MyApp(), brightness: brightness));
}
