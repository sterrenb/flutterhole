import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_add_form.dart';
import 'package:flutterhole_again/widget/status/status_app_bar.dart';

class BlacklistAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: 'Add to blacklist'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlacklistAddForm(),
      ),
    );
  }
}
