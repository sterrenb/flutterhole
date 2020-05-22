import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/convert.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/widgets/layout/animations/animated_opener.dart';
import 'package:flutterhole/widgets/layout/lists/open_url_tile.dart';

const String _wikipediaUrl =
    'https://en.wikipedia.org/wiki/List_of_DNS_record_types';

extension QueryStatusWithStyle on QueryStatus {
  IconData get toIconData {
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

  Color get toColor {
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

  String get toFullString {
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
        break;
      case QueryStatus.BlockedWithExternalNull:
        return 'Blocked (external, NULL)';
        break;
      case QueryStatus.BlockedWithExternalNXRA:
        return 'Blocked (external, NXRA)';
        break;
      case QueryStatus.Unknown:
        return 'Unknown';
        break;
      default:
        return 'Empty';
    }
  }
}

extension QueryTypeWithStyle on QueryType {
  String get toFullString => this == QueryType.UNKN
      ? 'Unknown'
      : this.toString().replaceAll('QueryType.', '');

  /// Results from https://en.wikipedia.org/wiki/List_of_DNS_record_types
  String get toDescription {
    switch (this) {
      case QueryType.A:
        return 'Returns a 32-bit IPv4 address, most commonly used to map hostnames to an IP address of the host, but it is also used for DNSBLs, storing subnet masks in RFC 1101, etc.';
      case QueryType.AAAA:
        return 'Returns a 128-bit IPv6 address, most commonly used to map hostnames to an IP address of the host.';
      case QueryType.ANY:
        return 'Deprecated.';
      case QueryType.SRV:
        return 'Generalized service location record, used for newer protocols instead of creating protocol-specific records such as MX.';
      case QueryType.SOA:
        return 'Specifies authoritative information about a DNS zone, including the primary name server, the email of the domain administrator, the domain serial number, and several timers relating to refreshing the zone.';
      case QueryType.PTR:
        return 'Pointer to a canonical name. Unlike a CNAME, DNS processing stops and just the name is returned. The most common use is for implementing reverse DNS lookups, but other uses include such things as DNS-SD.';
      case QueryType.TXT:
        return 'Originally for arbitrary human-readable text in a DNS record. Since the early 1990s, however, this record more often carries machine-readable data, such as specified by RFC 1464, opportunistic encryption, Sender Policy Framework, DKIM, DMARC, DNS-SD, etc.';
      case QueryType.UNKN:
      default:
        return 'Unknown.';
    }
  }
}

class SingleQueryDataTile extends StatelessWidget {
  const SingleQueryDataTile({
    Key key,
    @required this.query,
  }) : super(key: key);

  final QueryData query;

  String get _timeStamp =>
      '${query.timestamp.formattedDate}\t${query.timestamp.formattedTime} (${query.timestamp.fromNow})';

  Icon _buildQueryStatusIcon() {
    return Icon(
      query.queryStatus.toIconData,
      color: query.queryStatus.toColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpener(
      closed: (context) => ListTile(
        title: Text('${query.domain}'),
        isThreeLine: true,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$_timeStamp'),
            Text('${query.queryStatus.toFullString}',
                style: TextStyle(color: query.queryStatus.toColor)),
          ],
        ),
        trailing: _buildQueryStatusIcon(),
      ),
      opened: (context) => PiholeThemeBuilder(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Query data'),
          ),
          body: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(KIcons.timestamp),
                title: Text('$_timeStamp'),
                subtitle: Text('Timestamp'),
              ),
              ListTile(
                leading: Icon(KIcons.queryType),
                title: Text('${query.queryType.toFullString}'),
                subtitle: Text('DNS record type'),
                trailing: IconButton(
                  tooltip: 'Wat are DNS record types?',
                  icon: Icon(KIcons.moreInfo),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: Text('Wat are DNS record types?'),
                          children: <Widget>[
                            ...List<Widget>.generate(QueryType.values.length,
                                (index) {
                              final QueryType type =
                                  QueryType.values.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text('${type.toFullString}'),
                                subtitle: Text('${type.toDescription}'),
                              );
                            }),
                            OpenUrlTile(
                              url: _wikipediaUrl,
                              leading: Icon(KIcons.info),
                              title: Row(
                                children: <Widget>[
                                  Text('Learn more on '),
                                  Text(
                                    'Wikipedia',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              ListTile(
                leading: Icon(KIcons.domains),
                title: Text('${query.domain}'),
                subtitle: Text('Domain'),
              ),
              ListTile(
                leading: Icon(KIcons.clients),
                title: Text('${query.clientName}'),
                subtitle: Text('Client'),
              ),
              ListTile(
                leading: Icon(KIcons.queryStatus),
                title: Text('${query.queryStatus.toFullString}'),
                subtitle: Text('Status'),
                trailing: _buildQueryStatusIcon(),
              ),
              ListTile(
                leading: Icon(KIcons.pingInterval),
                title: Text('${query.replyDuration.inMicroseconds ~/ 100} ms'),
                subtitle: Text('Reply duration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
