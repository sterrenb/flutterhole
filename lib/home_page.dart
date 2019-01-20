import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text(widget.title),
            Icon(
              Icons.brightness_1,
              color: Colors.grey,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                print("click");
              })
        ],
      ),
      body: Text("body"),
    );
  }
}
