import 'package:flutter/material.dart';
import 'package:flutter_hole/app.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Brightness brightness = await getBrightness();
  quickActions();
  runApp(AppState(child: MyApp(), brightness: brightness));
}

Future<Brightness> getBrightness({String id = 'isDark'}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getBool(id) ?? false) ? Brightness.dark : Brightness.light;
}
