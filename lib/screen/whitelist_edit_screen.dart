import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_edit_form.dart';

class WhitelistEditScreen extends StatelessWidget {
  final String original;

  const WhitelistEditScreen({Key key, @required this.original})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: 'Editing $original'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WhitelistEditForm(original: original),
      ),
    );
  }
}
