import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/scaffold.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_edit_form.dart';

class WhitelistEditScreen extends StatelessWidget {
  final String original;

  const WhitelistEditScreen({Key key, @required this.original})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      titleString: 'Editing $original',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WhitelistEditForm(original: original),
      ),
    );
  }
}
