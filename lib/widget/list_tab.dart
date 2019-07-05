import 'package:flutter/material.dart';

class ListTab extends StatelessWidget {
  final String text;

  const ListTab(this.text);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text,
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: Theme.of(context).primaryColor)),
    );
  }
}
