import 'package:flutter/material.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/single_query_data_tile.dart';
import 'package:flutterhole/widgets/layout/animate_on_build.dart';

class ManyQueryTilesBuilder extends StatelessWidget {
  const ManyQueryTilesBuilder({
    Key key,
    @required this.queries,
  }) : super(key: key);

  final List<QueryData> queries;

  @override
  Widget build(BuildContext context) {
    return AnimateOnBuild(
      child: Scrollbar(
        child: ListView.builder(
            itemCount: queries.length,
            itemBuilder: (context, index) {
              final QueryData query = queries.elementAt(index);

              return SingleQueryDataTile(query: query);
            }),
      ),
    );
  }
}
