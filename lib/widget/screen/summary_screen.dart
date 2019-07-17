import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/summary/summary_builder.dart';

class SummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Dashboard',
      body: SummaryBuilder(),
    );
  }
}
