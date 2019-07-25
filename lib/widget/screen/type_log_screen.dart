import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/query/query_log_builder.dart';

class QueryTypeLogScreen extends StatelessWidget {
  final String queryType;

  const QueryTypeLogScreen({Key key, @required this.queryType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
        title: 'Logs for $queryType',
        withDrawer: false,
        body: QueryLogBuilder(
          searchString: queryType,
          filterType: FilterType.QueryType,
        ));
  }
}
