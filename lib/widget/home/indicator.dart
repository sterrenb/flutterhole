import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final Widget title;
  final double size;
  final GestureTapCallback onTap;

  const Indicator({
    Key key,
    @required this.color,
    @required this.title,
    this.size = 16.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
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
        ),
      ),
    );
  }
}
