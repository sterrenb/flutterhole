import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';

const Duration timeout = Duration(seconds: 1);

class _BlockedDomain extends StatelessWidget {
  final String title;
  final int hits;
  final DateTime hitAt = DateTime.now();

  _BlockedDomain({@required this.title, this.hits = 1});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          title: Row(
            children: <Widget>[
              Expanded(child: Text(title)),
              Tooltip(message: 'Blocked ${hits.toString()} times',
                  child: Chip(label: Text(hits.toString())))
            ],
          ),
          subtitle: Row(
            children: <Widget>[
              Icon(
                Icons.access_time,
                color: Colors.grey,
                size: 14.0,
              ),
              Tooltip(
                message: 'Last blocked at ${hitAt.toLocal()}',
                child: Text(hitAt.hour.toString().padLeft(2, '0') +
                    ':' +
                    hitAt.minute.toString().padLeft(2, '0') +
                    '.' +
                    hitAt.millisecond.toString()),
              ),
            ],
          ),
        ));
  }
}

class RecentlyBlocked extends StatefulWidget {
  @override
  RecentlyBlockedState createState() {
    return new RecentlyBlockedState();
  }
}

class RecentlyBlockedState extends State<RecentlyBlocked> {
  Timer _timer;
  static Map<String, int> _blockedDomains = Map();
  static String _lastDomain;

  Timer _startTimer() {
    return Timer.periodic(timeout, _onTimer);
  }

  void _onTimer(Timer timer) {
    Api.recentlyBlocked().then((String domain) {
      if (domain != _lastDomain) {
        _blockedDomains.update(domain, (int hits) {
          print('updating existing one with $hits hits');
          return hits + 1;
        }, ifAbsent: () => 1);
        _lastDomain = domain;
        setState(() {
          _blockedDomains = _blockedDomains;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('initState');
    setState(() {
      _timer = _startTimer();
      _blockedDomains = _blockedDomains;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivated!');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Iterable<String> keys = _blockedDomains.keys;
    Iterable<int> values = _blockedDomains.values;
    return ListView.builder(
        itemCount: _blockedDomains.length,
        itemBuilder: (BuildContext context, int index) {
          return _BlockedDomain(
            title: keys.elementAt(index),
            hits: values.elementAt(index),
          );
        });
  }
}
