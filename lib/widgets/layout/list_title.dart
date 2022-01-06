import 'package:flutter/material.dart';

class ListTitle extends StatelessWidget {
  final String title;
  const ListTitle(
    this.title, {
    Key? key,
  })  : assert(title.length > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .subtitle2
            ?.copyWith(color: Theme.of(context).secondaryHeaderColor),
      ),
    );
  }
}
