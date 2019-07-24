import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final Widget title;
  final double size;

  const Indicator({
    Key key,
    @required this.color,
    @required this.title,
    this.size = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: color,
            ),
          ),
        ),
        title,
      ],
    );
  }
}
