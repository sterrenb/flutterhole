import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterHole',
      home: Scaffold(
        body: Center(
          child: Text("Hi"),
        ),
      ),
    );
  }
}
