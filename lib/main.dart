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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.indigo,
        // accentColor: Colors.deepOrangeAccent,
        // scaffoldBackgroundColor: Colors.grey[300],
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.purple,
        // ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // primaryColor: Colors.orange,
        accentColor: Colors.orangeAccent,
        // scaffoldBackgroundColor: Colors.purple,
        // backgroundColor: Colors.green,
      ),
      themeMode: themeMode.state,
      home: const HomeScreen(),
    );
  }
}
