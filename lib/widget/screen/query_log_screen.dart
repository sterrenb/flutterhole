import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/query_log_builder.dart';
import 'package:flutterhole_again/widget/scaffold.dart';

class QueryLogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Query Log',
      body: QueryLogBuilder(),
    );
  }
}
