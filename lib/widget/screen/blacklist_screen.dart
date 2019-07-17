import 'package:flutter/material.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/widget/blacklist/blacklist_add_form.dart';
import 'package:flutterhole/widget/blacklist/blacklist_builder.dart';
import 'package:flutterhole/widget/blacklist/blacklist_edit_form.dart';
import 'package:flutterhole/widget/blacklist/blacklist_floating_action_button.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class BlacklistAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
      titleString: 'Add to blacklist',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlacklistAddForm(),
      ),
    );
  }
}

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

class BlacklistViewScreen extends StatefulWidget {
  @override
  _BlacklistViewScreenState createState() => _BlacklistViewScreenState();
}

class _BlacklistViewScreenState extends State<BlacklistViewScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Blacklist',
      body: BlacklistBuilder(),
      floatingActionButton: BlacklistFloatingActionButton(),
    );
  }
}
