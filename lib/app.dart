import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final title = 'FlutterHole';

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) =>
          ThemeData(
            primarySwatch: Colors.indigo,
            brightness: brightness,
          ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: title,
          theme: theme,
          debugShowCheckedModeBanner: false,
          home: SettingsScreen(),
        );
      },
    );
  }
}
