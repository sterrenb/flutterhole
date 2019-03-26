import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/friendly_exception.dart';

/// The default timeout [Duration] for retrieving the most recently blocked domain.
const Duration defaultTimeout = Duration(seconds: 1);

/// A blocked domain entry, used in [RecentlyBlocked].
class _BlockedDomain extends StatefulWidget {
  /// The domain title.
  final String title;

  /// The amount of hits since the initial entry.
  final int hits;

  _BlockedDomain({@required this.title, this.hits = 1});

  @override
  _BlockedDomainState createState() {
    return new _BlockedDomainState();
  }
}

class _BlockedDomainState extends State<_BlockedDomain> {
  DateTime hitAt = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Row(
        children: <Widget>[
          Expanded(child: Text(widget.title)),
          Tooltip(
              message: 'Blocked ${widget.hits.toString()} times',
              child: Chip(label: Text(widget.hits.toString())))
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
            message: 'First blocked at ${hitAt.toLocal()}',
            child: Text(hitAt.hour.toString().padLeft(2, '0') +
                ':' +
                hitAt.minute.toString().padLeft(2, '0') +
                '.' +
                hitAt.second.toString().padLeft(2, '0')),
          ),
        ],
      ),
    ));
  }
}

/// A widget that shows recently blocked domains and retrieves newly blocked domains based on the [defaultTimeout].
class RecentlyBlocked extends StatefulWidget {
  @override
  RecentlyBlockedState createState() {
    return new RecentlyBlockedState();
  }
}

class RecentlyBlockedState extends State<RecentlyBlocked> {
  /// The timer used to periodically ping the Pi-hole.
  Timer timer;

  /// The local store of blocked domains, pairing domain name and amount of hits.
  static Map<String, int> blockedDomains = Map();

  /// The most recently obtained blocked domain.
  static String lastDomain;

  /// The default polling rate.
  double sliderValue = 1.0;

  /// The local store of any error message.
  String errorMessage;

  static final ApiProvider provider = ApiProvider();

  Timer _startTimer({Duration timeout = defaultTimeout}) {
    return Timer.periodic(timeout, _onTimer);
  }

  /// Updates the blocked domains mapping.
  ///
  /// Sets an error message when the API returns an error.
  void _onTimer(Timer timer) {
    provider.recentlyBlocked().then((String domain) {
      if (domain != lastDomain) {
        blockedDomains.update(domain, (int hits) {
          return hits + 1;
        }, ifAbsent: () => 1);
        lastDomain = domain;
        setState(() {});
      }
    }, onError: (e) {
      timer.cancel();
      setState(() {
        errorMessage = e.toString();
      });
    });
  }

  /// Converts the polling rate slider value to an integer.
  int _sliderToInt(double sliderValue) => (sliderValue * 1000).toInt();

  @override
  void initState() {
    super.initState();
    setState(() {
      timer = _startTimer();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Iterable<String> keys = blockedDomains.keys;
    Iterable<int> values = blockedDomains.values;

    const double _min = 0.1;
    const double _max = 5.0;
    Widget body;

    if (errorMessage != null) {
      body = Expanded(
          child: Center(child: FriendlyException(message: errorMessage)));
    } else {
      body = (blockedDomains.length == 0)
          ? Expanded(child: Center(child: CircularProgressIndicator()))
          : Expanded(
              child: Scrollbar(
                child: ListView.builder(
                    itemCount: blockedDomains.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _BlockedDomain(
                        title: keys.elementAt(index),
                        hits: values.elementAt(index),
                      );
                    }),
              ),
            );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text('Polling rate'),
                  Text('(${_sliderToInt(sliderValue)}ms)'),
                ],
              ),
              Expanded(
                child: Slider(
                  label: 'Ping rate',
                  value: sliderValue,
                  min: _min,
                  max: _max,
                  onChanged: (double newValue) {
                    setState(() {
                      sliderValue = newValue;
                    });
                  },
                  onChangeEnd: (double newValue) {
                    timer.cancel();
                    setState(() {
                      timer = _startTimer(
                          timeout:
                              Duration(milliseconds: _sliderToInt(newValue)));
                    });
                  },
                ),
              ),
              FlatButton(
                  child: Text('Reset'),
                  onPressed: () {
                    setState(() {
                      blockedDomains = Map();
                      lastDomain = '';
                    });
                  })
            ],
          ),
        ),
        body,
        LinearProgressIndicator(),
      ],
    );
  }
}
