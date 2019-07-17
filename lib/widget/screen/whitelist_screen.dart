import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/whitelist/whitelist_add_form.dart';
import 'package:flutterhole/widget/whitelist/whitelist_builder.dart';
import 'package:flutterhole/widget/whitelist/whitelist_edit_form.dart';
import 'package:flutterhole/widget/whitelist/whitelist_floating_action_button.dart';

class WhitelistAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      titleString: 'Add to whitelist',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WhitelistAddForm(),
      ),
    );
  }
}

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

class WhitelistViewScreen extends StatefulWidget {
  @override
  _WhitelistViewScreenState createState() => _WhitelistViewScreenState();
}

class _WhitelistViewScreenState extends State<WhitelistViewScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Whitelist',
      body: WhitelistBuilder(),
      floatingActionButton: WhitelistFloatingActionButton(),
    );
  }
}
