import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_add_form.dart';
import 'package:flutterhole_again/widget/scaffold.dart';

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
