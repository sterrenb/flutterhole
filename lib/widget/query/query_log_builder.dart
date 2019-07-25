import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/api/query.dart';
import 'package:flutterhole/bloc/api/whitelist.dart' as White;
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/browser.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/layout/search_options.dart';
import 'package:provider/provider.dart';

String dnsSecStatusToString(DnsSecStatus dnsSecStatus) {
  return dnsSecStatus == DnsSecStatus.Empty
      ? 'no DNSSEC'
      : dnsSecStatus.toString().replaceAll('DnsSecStatus.', '');
}

String queryTypeToString(QueryType type) {
  return type == QueryType.UNKN
      ? 'Unknown'
      : type.toString().replaceAll('QueryType.', '');
}

String queryStatusToString(QueryStatus status) {
  switch (status) {
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

enum FilterType {
  Client,
  QueryType,
}

class QueryLogBuilder extends StatefulWidget {
  final String searchString;
  final FilterType filterType;

  QueryLogBuilder({
    Key key,
    this.searchString,
    this.filterType,
  }) : super(key: key);

  @override
  _QueryLogBuilderState createState() {
    BlocEvent event;

    switch (filterType) {
      case FilterType.Client:
        event = FetchForClient(searchString);
        break;
      case FilterType.QueryType:
        event = FetchForQueryType(stringToQueryType(searchString));
        break;
      default:
        event = Fetch();
    }

    return _QueryLogBuilderState(event);
  }
}

class _QueryLogBuilderState extends State<QueryLogBuilder> {
  Completer _refreshCompleter;

  List<Query> _queryCache;

  Whitelist _whitelistCache;
  Blacklist _blacklistCache;

  final BlocEvent fetchEvent;

  _QueryLogBuilderState(this.fetchEvent);

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
    _queryCache = [];

//    fetchEvent = Fetch();
//
//    if (widget.client != null) {
//      fetchEvent = FetchForClient(widget.client);
//    }
  }

  @override
  Widget build(BuildContext context) {
    final QueryBloc queryBloc = BlocProvider.of<QueryBloc>(context);
    final White.WhitelistBloc whitelistBloc =
    BlocProvider.of<White.WhitelistBloc>(context);
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener(
            bloc: queryBloc,
            listener: (context, state) {
              if (state is BlocStateEmpty<List<Query>>) {
                queryBloc.dispatch(fetchEvent);
              }

              if (state is BlocStateSuccess<List<Query>> ||
                  state is BlocStateError<List<Query>>) {
                _refreshCompleter?.complete();
                _refreshCompleter = Completer();

                if (state is BlocStateSuccess<List<Query>>) {
                  setState(() {
                    _queryCache = state.data;
                  });
                }
              }
            }),
        BlocListener(
          bloc: whitelistBloc,
          listener: (context, state) {
            if (state is BlocStateSuccess<Whitelist>) {
              setState(() {
                _whitelistCache = state.data;
              });
            }
          },
        ),
        BlocListener(
          bloc: blacklistBloc,
          listener: (context, state) {
            if (state is BlocStateSuccess<Blacklist>) {
              setState(() {
                _blacklistCache = state.data;
              });
            }
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () {
          queryBloc.dispatch(fetchEvent);
          whitelistBloc.dispatch(Fetch());
          blacklistBloc.dispatch(Fetch());
          return _refreshCompleter.future;
        },
        child: BlocBuilder(
            bloc: queryBloc,
            builder: (BuildContext context, BlocState state) {
              if (state is BlocStateSuccess<List<Query>> ||
                  state is BlocStateLoading<List<Query>> &&
                      _queryCache != null &&
                      _queryCache.length > 0) {
                if (state is BlocStateSuccess<List<Query>>) {
                  _queryCache = state.data;
                }

                List<Query> filteredItems = [];

                final SearchOptions search =
                Provider.of<SearchOptions>(context);
                final String str = search.str.trim();
                if (str.isNotEmpty) {
                  _queryCache.forEach((query) {
                    if (query.entry.contains(str)) {
                      filteredItems.add(query);
                    }
                  });

                  if (filteredItems.isEmpty) {
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Center(child: Text('No queries found.')),
                        ),
                      ],
                    );
                  }
                }

                final items =
                filteredItems.isNotEmpty ? filteredItems : _queryCache;

                return Scrollbar(
                  child: ListView.separated(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Query query = items[index];

                      final bool isOnWhitelist = _whitelistCache != null &&
                          _whitelistCache.list.contains(query.entry);
                      final bool isOnBlacklist = _blacklistCache != null &&
                          _blacklistCache.exact.contains(
                              BlacklistItem.exact(entry: query.entry));

                      final actions = <Widget>[
                        IconButton(
                            icon: Icon(Icons.open_in_browser),
                            tooltip:
                            'Open in browser ${Uri.parse(query.entry)
                                .toString()}',
                            onPressed: () {
                              launchURL(query.entry);
                            }),
                        isOnWhitelist
                            ? IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Remove from whitelist',
                          onPressed: () {
                            whitelistBloc
                                .dispatch(White.Remove(query.entry));
                            showSnackBar(
                                context,
                                Text(
                                    'Removing ${query.entry} from whitelist'));
                          },
                        )
                            : isOnBlacklist
                            ? null
                            : IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: Theme
                                .of(context)
                                .iconTheme
                                .color,
                          ),
                          tooltip: 'Add to whitelist',
                          onPressed: () {
                            whitelistBloc
                                .dispatch(White.Add(query.entry));
                            showSnackBar(
                                context,
                                Text(
                                    'Adding ${query.entry} to whitelist'));
                          },
                        ),
                        isOnBlacklist
                            ? IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Remove from blacklist',
                          onPressed: () {
                            blacklistBloc.dispatch(Remove(
                                BlacklistItem.exact(entry: query.entry)));
                            showSnackBar(
                                context,
                                Text(
                                    'Removing ${query.entry} from blacklist'));
                          },
                        )
                            : isOnWhitelist
                            ? null
                            : IconButton(
                          icon: Icon(
                            Icons.cancel,
                          ),
                          tooltip: 'Add to blacklist',
                          onPressed: () {
                            blacklistBloc.dispatch(Add(
                                BlacklistItem.exact(
                                    entry: query.entry)));
                            showSnackBar(
                                context,
                                Text(
                                    'Adding ${query.entry} to blacklist'));
                          },
                        ),
                      ];

                      return QueryExpansionTile(
                        query: query,
                        actions: actions,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(height: 1);
                    },
                  ),
                );
              }

              if (state is BlocStateError<List<Query>>) {
                return ErrorMessage(errorMessage: state.e.message);
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}

class QueryExpansionTile extends StatelessWidget {
  final Query query;

  final List<Widget> actions;

  const QueryExpansionTile(
      {Key key, @required this.query, this.actions = const []})
      : super(key: key);

//  static final _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final bool successful = (query.queryStatus == QueryStatus.Cached ||
        query.queryStatus == QueryStatus.Forwarded);
    return ExpansionTile(
      key: Key(query.entry),
      backgroundColor: Theme
          .of(context)
          .dividerColor,
      leading: _expansionTileLeading(query, successful),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(query.entry),
          Text(
            timestampFormatter.format(query.time),
            style: Theme
                .of(context)
                .textTheme
                .caption,
          ),
          Text(
            queryStatusToString(query.queryStatus),
            style: Theme
                .of(context)
                .textTheme
                .caption
                .copyWith(color: successful ? Colors.green : Colors.red),
          )
        ],
      ),
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                ListTile(
                  title: Text(timestampFormatter.format(query.time)),
                  subtitle: Text('Time'),
                ),
                ListTile(
                  title: Text(queryTypeToString(query.queryType)),
                  subtitle: Text('Type'),
                ),
                ListTile(
                  title: Text(query.client),
                  subtitle: Text('Client'),
                ),
                ListTile(
                  title: Text(queryStatusToString(query.queryStatus)),
                  subtitle: Text('Query status'),
                ),
                ListTile(
                  title: Text(dnsSecStatusToString(query.dnsSecStatus)),
                  subtitle: Text('DNSSEC'),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: ButtonBar(
                    children: actions,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  _expansionTileLeading(Query query, bool successful) {
    final color = successful ? Colors.green : Colors.red;
    IconData data = successful ? Icons.check_circle : Icons.cancel;
    switch (query.queryStatus) {
      case QueryStatus.BlockedWithGravity:
        data = Icons.remove_circle;
        break;
      case QueryStatus.Forwarded:
        break;
      case QueryStatus.Cached:
        data = Icons.cached;
        break;
      case QueryStatus.BlockedWithRegexWildcard:
        data = Icons.code;
        break;
      default:
        break;
    }

    return Icon(data, color: color);
  }
}
