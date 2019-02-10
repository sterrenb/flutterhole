import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/status_icon.dart';

/// A widget creating a [Row] of a [StatusIcon] and [Text] with a [title].
class StatusTitle extends StatelessWidget {
  const StatusTitle({
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
