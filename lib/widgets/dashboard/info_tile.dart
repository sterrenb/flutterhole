import 'package:flutter/material.dart';

/// The material colors corresponding to the Pi-hole admin dashboard.
const piColors = [Colors.green, Colors.blue, Colors.orange, Colors.red];

/// A Card that shows a small Text with the [title] and a large Text with the [value].
class InfoTile extends StatelessWidget {
  /// The human friendly title.
  final String title;

  /// The human friendly value.
  final String value;

  const InfoTile({Key key, @required this.title, @required this.value})
      : super(key: key);

  /// The index used to cycle through [piColors].
  static int _colorIndex = 0;

  /// Cycles through [piColors] sequentially.
  MaterialColor _nextColor() {
    MaterialColor color = piColors[_colorIndex];
    _colorIndex = (_colorIndex + 1) % (piColors.length);
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
