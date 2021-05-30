import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/home_screen.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? newValue) {
    print('[${provider.name ?? provider.runtimeType}] value: $newValue');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp(ProviderScope(observers: [Logger()], child: MyApp()));
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.orangeAccent,
      ),
      themeMode: themeMode.state,
      home: const HomeScreen(),
      // home: const QueryLogScreen(),
    );
  }
}
