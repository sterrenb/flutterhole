import 'package:flutter/material.dart';

class PercentageBox extends StatelessWidget {
  final double width;
  final double fraction;

  const PercentageBox({Key key, @required this.width, @required this.fraction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: <Widget>[
        ColoredBox(width: fraction * width, color: Colors.green),
        ColoredBox(width: width, color: Theme.of(context).dividerColor),
      ],
    );
  }
}

class ColoredBox extends StatelessWidget {
  final double width;
  final Color color;

  const ColoredBox({
    Key key,
    @required this.width,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 2,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}
