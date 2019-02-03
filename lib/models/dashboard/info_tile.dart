import 'package:flutter/material.dart';

const _colors = [Colors.green, Colors.blue, Colors.orange, Colors.red];

/// A Card that shows a small Text with the [title] and a large Text with the [value].
class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile({Key key, @required this.title, @required this.value})
      : super(key: key);

  static int _colorIndex = 0;

  MaterialColor _nextColor() {
    MaterialColor color = _colors[_colorIndex];
    _colorIndex = (_colorIndex + 1) % (_colors.length);
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: _nextColor(),
        child: Center(
          child: ListTile(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
