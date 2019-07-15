import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/scaffold.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_add_form.dart';

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
