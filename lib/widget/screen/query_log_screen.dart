import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/query/query_log_builder.dart';

class QueryLogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
      title: 'Query Log',
      body: QueryLogBuilder(),
    );
  }
}
