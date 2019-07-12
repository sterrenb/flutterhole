import 'package:flutter/material.dart';

class ListTab extends StatelessWidget {
  final String title;

  const ListTab(this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Theme.of(context).primaryColor)),
    );
  }
}
