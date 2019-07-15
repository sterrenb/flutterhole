import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_edit_form.dart';
import 'package:flutterhole_again/widget/scaffold.dart';

class BlacklistEditScreen extends StatelessWidget {
  final BlacklistItem original;

  const BlacklistEditScreen({Key key, @required this.original})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      titleString: 'Editing ${original.entry}',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlacklistEditForm(original: original),
      ),
    );
  }
}
