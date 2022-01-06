import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/about_view.dart';
import 'package:flutterhole/views/dashboard_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/ui/double_back_to_close_app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      SettingsService.provider.overrideWithValue(SettingsService(preferences))
    ],
    child: const MyApp(),
  ));
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp(
      title: 'FlutterHole',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      showSemanticsDebugger: false,
      home: const DoubleBackToCloseApp(child: DashboardView()),
      // home: const SinglePiEditView(),
    );
  }
}
