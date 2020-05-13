import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/pihole_api/data/models/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';

IconData _queryStatusToIconData(QueryStatus queryStatus) {
  switch (queryStatus) {
    case QueryStatus.Forwarded:
      return KIcons.forwarded;
    case QueryStatus.Cached:
      return KIcons.cached;
    case QueryStatus.BlockedWithGravity:
    case QueryStatus.BlockedWithRegexWildcard:
    case QueryStatus.BlockedWithBlacklist:
    case QueryStatus.BlockedWithExternalIP:
    case QueryStatus.BlockedWithExternalNull:
    case QueryStatus.BlockedWithExternalNXRA:
      return KIcons.blocked;
    case QueryStatus.Unknown:
    default:
      return KIcons.unknown;
  }
}

Color _queryStatusToColor(QueryStatus queryStatus) {
  switch (queryStatus) {
    case QueryStatus.Forwarded:
      return KColors.forwarded;
    case QueryStatus.Cached:
      return KColors.cached;
    case QueryStatus.BlockedWithGravity:
    case QueryStatus.BlockedWithRegexWildcard:
    case QueryStatus.BlockedWithBlacklist:
    case QueryStatus.BlockedWithExternalIP:
    case QueryStatus.BlockedWithExternalNull:
    case QueryStatus.BlockedWithExternalNXRA:
      return KColors.blocked;
    case QueryStatus.Unknown:
    default:
      return KColors.unknown;
  }
}

class SingleQueryDataTile extends StatelessWidget {
  const SingleQueryDataTile({
    Key key,
    @required this.query,
  }) : super(key: key);

  final QueryData query;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${query.domain}'),
      isThreeLine: true,
      subtitle: Text(
        '${query.timestamp.formattedDate}\t${query.timestamp.formattedTime}\n${query.timestamp.fromNow}',
      ),
      trailing: Icon(
        _queryStatusToIconData(query.queryStatus),
        color: _queryStatusToColor(query.queryStatus),
      ),
    );
  }
}
