import 'package:flutter/material.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/queries_search_notifier.dart';
import 'package:provider/provider.dart';

extension QueryDataSearchable on QueryData {
  String get searchableString => [
        queryType,
        domain,
        clientName,
        queryStatus,
        dnsSecStatus,
      ].toString().toLowerCase();
}

typedef Widget SearchListBuilder(BuildContext context, List<QueryData> matches);

class QueriesSearchListBuilder extends StatelessWidget {
  const QueriesSearchListBuilder({
    Key key,
    @required this.initialData,
    @required this.builder,
  }) : super(key: key);

  final List<QueryData> initialData;
  final SearchListBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<QueriesSearchNotifier>(builder: (
      BuildContext context,
      QueriesSearchNotifier notifier,
      _,
    ) {
      List<QueryData> searchedQueries;

      if (notifier.isSearching && notifier.searchQuery.isNotEmpty) {
        searchedQueries = initialData.where((element) {
          final string = element.searchableString;
          print('checking for "${notifier.searchQuery}" in "$string');
          return string.contains(notifier.searchQuery);
        }).toList();
      }

      final List<QueryData> toUse = searchedQueries ?? initialData;

      return builder(context, toUse);
    });
  }
}
