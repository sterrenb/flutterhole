import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  final Widget home;

  const MyApp({Key key, @required this.home}) : super(key: key);

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
      data: (brightness) => ThemeData(
            primarySwatch: Colors.indigo,
            brightness: brightness,
          ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: title,
          theme: theme,
          debugShowCheckedModeBanner: false,
          home: widget.home,
        );
      },
    );
  }
}
