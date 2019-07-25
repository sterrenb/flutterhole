import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/query/query_log_builder.dart';

class ClientLogScreen extends StatelessWidget {
  final String client;

  const ClientLogScreen({Key key, @required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchScaffold(
        title: 'Logs for $client',
        withDrawer: false,
        body: QueryLogBuilder(
          searchString: client,
          filterType: FilterType.Client,
        ));
  }
}
