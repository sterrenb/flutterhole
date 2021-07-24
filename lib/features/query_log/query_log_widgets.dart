import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/formatting/date_formatting.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/logging/log_widgets.dart';
import 'package:pihole_api/pihole_api.dart';

extension QueryStatusWithStyle on QueryStatus {
  IconData get iconData {
    switch (this) {
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

  Color toColor() {
    switch (this) {
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

  String toFullString() {
    switch (this) {
      case QueryStatus.BlockedWithGravity:
        return 'Blocked (gravity)';
      case QueryStatus.Forwarded:
        return 'OK (forwarded)';
      case QueryStatus.Cached:
        return 'OK (cached)';
      case QueryStatus.BlockedWithRegexWildcard:
        return 'Blocked (regex/wildcard)';
      case QueryStatus.BlockedWithBlacklist:
        return 'Blocked (blacklist)';
      case QueryStatus.BlockedWithExternalIP:
        return 'Blocked (external, IP)';
      case QueryStatus.BlockedWithExternalNull:
        return 'Blocked (external, NULL)';
      case QueryStatus.BlockedWithExternalNXRA:
        return 'Blocked (external, NXRA)';
      case QueryStatus.Unknown:
        return 'Unknown';
      default:
        return 'Empty';
    }
  }
}

class QueryItemTile extends StatelessWidget {
  const QueryItemTile(
    this.item, {
    Key? key,
  }) : super(key: key);

  final QueryItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.domain),
      subtitle: Row(
        children: [
          Icon(
            item.queryStatus.iconData,
            color: item.queryStatus.toColor(),
            size: Theme.of(context).textTheme.caption!.fontSize,
          ),
          SizedBox(width: Theme.of(context).textTheme.caption!.fontSize! / 2),
          Text(item.queryStatus.toFullString()),
        ],
      ),
      // subtitle: Text(item.queryStatus.toString() + '\n' + item.clientName),
      isThreeLine: false,
      // leading: Icon(KIcons.darkTheme),
      trailing: Column(
        // mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.timestamp.hms,
            style: Theme.of(context).textTheme.caption,
          ),
          DifferenceText(item.timestamp),
          Text(
            '${item.delta}ms',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      onTap: () {
        showModal(
            context: context,
            builder: (context) => DialogListBase(
                  header: DialogHeader(title: item.domain),
                  // canCancel: false,
                  // onSelect: () {
                  //   Navigator.of(context).pop();
                  // },
                  // theme: Theme.of(context),
                  body: SliverList(
                    delegate: SliverChildListDelegate([
                      SelectableCodeCard(item.toReadableJson()),
                    ]),
                  ),
                ));
      },
    );
  }
}
