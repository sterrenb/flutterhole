import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      SettingsService.provider.overrideWithValue(SettingsService(preferences))
    ],
    child: const App(),
  ));
}
