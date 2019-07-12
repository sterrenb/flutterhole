import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/default_drawer.dart';
import 'package:flutterhole_again/widget/status_app_bar.dart';
import 'package:flutterhole_again/widget/summary_builder.dart';

class SummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: StatusAppBar(title: 'Dashboard'),
      drawer: DefaultDrawer(),
      body: SummaryBuilder(),
    );
  }
}
