import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/scaffold.dart';
import 'package:flutterhole_again/widget/summary_builder.dart';

class SummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Dashboard',
      body: SummaryBuilder(),
    );
  }
}
