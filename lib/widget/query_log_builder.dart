import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole_again/bloc/query/query_bloc.dart';
import 'package:flutterhole_again/bloc/query/query_event.dart';
import 'package:flutterhole_again/bloc/query/query_state.dart';
import 'package:flutterhole_again/model/query.dart';
import 'package:intl/intl.dart';

import 'error_message.dart';

class QueryLogBuilder extends StatefulWidget {
  @override
  _QueryLogBuilderState createState() => _QueryLogBuilderState();
}

class _QueryLogBuilderState extends State<QueryLogBuilder> {
  Completer _refreshCompleter;

  List<Query> _cache;

  static final _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer();
    _cache = [];
  }

  String _dnsSecStatusToString(DnsSecStatus dnsSecStatus) {
    return dnsSecStatus == DnsSecStatus.Empty
        ? 'no DNSSEC'
        : dnsSecStatus.toString().replaceAll('DnsSecStatus.', '');
  }

  String _queryTypeToString(QueryType type) {
    return type == QueryType.UNKN
        ? 'Unknown'
        : type.toString().replaceAll('QueryType.', '');
  }

  Widget _queryStatusToWidget(QueryStatus status) {
    final str = _queryStatusToString(status);
    return Text(
      str,
      style: Theme.of(context).textTheme.caption,
    );
  }

  String _queryStatusToString(QueryStatus status) {
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

  @override
  Widget build(BuildContext context) {
    final QueryBloc queryBloc = BlocProvider.of<QueryBloc>(context);
    return BlocListener(
      bloc: queryBloc,
      listener: (context, state) {
        if (state is QueryStateEmpty) {
          queryBloc.dispatch(FetchQueries());
        }

        if (state is QueryStateSuccess || state is QueryStateError) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          if (state is QueryStateSuccess) {
            setState(() {
              _cache = state.queries;
            });
          }
        }
      },
      child: RefreshIndicator(
        onRefresh: () {
          queryBloc.dispatch(FetchQueries());
          return _refreshCompleter.future;
        },
        child: BlocBuilder(
            bloc: queryBloc,
            builder: (BuildContext context, QueryState state) {
              if (state is QueryStateSuccess ||
                  state is QueryStateLoading && _cache != null) {
                if (state is QueryStateSuccess) {
                  _cache = state.queries;
                }

                return Scrollbar(
                  child: ListView.separated(
                    itemCount: _cache.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Query query = _cache[index];
                      return ExpansionTile(
                        key: Key(query.entry),
                        backgroundColor: Theme.of(context).dividerColor,
                        leading: (query.queryStatus == QueryStatus.Cached ||
                                query.queryStatus == QueryStatus.Forwarded)
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(query.entry),
                            Text(
                              _formatter.format(query.time),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            _queryStatusToWidget(query.queryStatus),
//                            _dnsSecStatusToText(query.dnsSecStatus)
                          ],
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text(_formatter.format(query.time)),
                            subtitle: Text('Time'),
                          ),
                          ListTile(
                            title: Text(_queryTypeToString(query.queryType)),
                            subtitle: Text('Type'),
                          ),
                          ListTile(
                            title: Text(query.client),
                            subtitle: Text('Client'),
                          ),
                          ListTile(
                            title:
                                Text(_queryStatusToString(query.queryStatus)),
                            subtitle: Text('Query status'),
                          ),
                          ListTile(
                            title:
                                Text(_dnsSecStatusToString(query.dnsSecStatus)),
                            subtitle: Text('DNSSEC'),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(height: 1);
                    },
                  ),
                );
              }

              if (state is QueryStateError) {
                return ErrorMessage(errorMessage: state.e.message);
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
