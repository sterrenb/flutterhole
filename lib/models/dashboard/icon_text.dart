import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/status_icon.dart';

class IconText extends StatelessWidget {
  const IconText({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        StatusIcon(),
        Text(title),
      ],
    );
  }
}
