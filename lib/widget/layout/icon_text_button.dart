import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback onPressed;
  final Color color;

  const IconTextButton(
      {Key key,
      @required this.title,
      @required this.icon,
      this.onPressed,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
