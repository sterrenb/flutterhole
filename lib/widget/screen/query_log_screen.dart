import 'package:flutter/material.dart';
import 'package:flutterhole_again/widget/layout/scaffold.dart';
import 'package:flutterhole_again/widget/query/query_log_builder.dart';

class QueryLogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Query Log',
      body: QueryLogBuilder(),
    );
  }
}
