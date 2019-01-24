import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';

const Duration defaultTimeout = Duration(seconds: 1);

class _BlockedDomain extends StatefulWidget {
  final String title;
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
  double _sliderValue = 1.0;

  Timer _startTimer({Duration timeout = defaultTimeout}) {
    return Timer.periodic(timeout, _onTimer);
  }

  void _onTimer(Timer timer) {
    print('onTimer ${timer.tick}');
    try {
      Api.recentlyBlocked().then((String domain) {
        if (domain != _lastDomain) {
          _blockedDomains.update(domain, (int hits) {
            print('updating existing one with $hits hits');
            return hits + 1;
          }, ifAbsent: () => 1);
          _lastDomain = domain;
          setState(() {});
        }
      });
    } catch (e) {
      print(e);
    }
  }

  int _sliderToInt(double sliderValue) => (sliderValue * 1000).toInt();

  @override
  void initState() {
    super.initState();
    setState(() {
      _timer = _startTimer();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Iterable<String> keys = _blockedDomains.keys;
    Iterable<int> values = _blockedDomains.values;

    const double _min = 0.1;
    const double _max = 5.0;
    final Widget _body = (_blockedDomains.length == 0)
        ? Expanded(child: Center(child: CircularProgressIndicator()))
        : Expanded(
      child: ListView.builder(
          itemCount: _blockedDomains.length,
          itemBuilder: (BuildContext context, int index) {
            return _BlockedDomain(
              title: keys.elementAt(index),
              hits: values.elementAt(index),
            );
          }),
    );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text('Polling rate'),
                  Text('(${_sliderToInt(_sliderValue)}ms)'),
                ],
              ),
              Expanded(
                child: Slider(
                  label: 'Ping rate',
                  value: _sliderValue,
                  min: _min,
                  max: _max,
                  onChanged: (double newValue) {
                    setState(() {
                      _sliderValue = newValue;
                    });
                  },
                  onChangeEnd: (double newValue) {
                    print('final value: ${_sliderToInt(newValue)}');
                    _timer.cancel();
                    setState(() {
                      _timer = _startTimer(
                          timeout:
                          Duration(milliseconds: _sliderToInt(newValue)));
                    });
                  },
                ),
              ),
            ],
          ),
        ),
//        ProgressIndicatorDemo(timeout: Duration(milliseconds: 50),),
        _body,
      ],
    );
  }
}
