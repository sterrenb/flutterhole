import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_add_form.dart';

class WhitelistAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: 'Add to whitelist'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WhitelistAddForm(),
      ),
    );
  }
}
