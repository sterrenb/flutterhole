import 'package:flutter/material.dart';

class ListTitle extends StatelessWidget {
  const ListTitle({
    Key key,
    @required this.message,
    this.color,
  })  : assert(message != null),
        super(key: key);

  final String message;

  /// The [message] color.
  final Color color;

  Color _getColor(BuildContext context) =>
      color ?? Theme.of(context).accentColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(color: _getColor(context)),
      ),
    );
  }
}
