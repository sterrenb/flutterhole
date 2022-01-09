import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/dashboard_view.dart';
import 'package:flutterhole/widgets/ui/double_back_to_close_app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends HookConsumerWidget {
  const App({Key? key}) : super(key: key);

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
