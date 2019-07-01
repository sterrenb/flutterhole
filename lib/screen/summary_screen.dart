import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/status_icon.dart';
import 'package:flutterhole_again/widget/toggle_button.dart';

import '../summary.dart';

class SummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text('Dashboard'),
            StatusIcon(),
          ],
        ),
        actions: <Widget>[
          ToggleButton(),
        ],
      ),

//      drawer: DefaultDrawer(allowConfigSelection: false),
      body: Summary(),
    );
  }
}
