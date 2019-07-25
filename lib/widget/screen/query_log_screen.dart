import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/query/query_log_builder.dart';

class QueryLogScreen extends StatelessWidget {
  final String search;
  final bool withDrawer;

  const QueryLogScreen({Key key, this.search = '', this.withDrawer = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
      initialValue: search,
      withDrawer: withDrawer,
      title: 'Query Log',
      body: QueryLogBuilder(searchString: search),
    );
  }
}
