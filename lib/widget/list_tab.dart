import 'package:flutter/material.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class ListTab extends StatelessWidget {
  final String title;

  const ListTab(this.title);

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);
    return ListTile(
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .subtitle
              .copyWith(color: _theme.accentColor)),
    );
  }
}
