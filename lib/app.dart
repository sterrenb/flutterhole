import 'package:flutter/material.dart';
import 'package:flutter_hole/screens/home_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'FlutterHole';
    return MaterialApp(
      title: title,
//      theme: ThemeData.dark(),
      theme: ThemeData(brightness: Brightness.dark),
      home: HomeScreen(title: title),
    );
  }
}
