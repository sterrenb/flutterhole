import 'package:flutter/material.dart';
import 'package:flutter_hole/app.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/quick_actions.dart';

void main() async {
//  Brightness brightness = await getBrightness();
  quickActions();
  runApp(AppState(child: MyApp(), brightness: Brightness.light));
}
