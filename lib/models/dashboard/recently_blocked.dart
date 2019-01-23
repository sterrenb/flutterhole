import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api.dart';

const Duration timeout = Duration(seconds: 1);

class RecentlyBlocked extends StatefulWidget {
  @override
  RecentlyBlockedState createState() {
    return new RecentlyBlockedState();
  }
}

class RecentlyBlockedState extends State<RecentlyBlocked> {
  Timer _timer;
  static List<String> domains;
  static int repeat = 0;

  Timer _startTimer() {
    return Timer.periodic(timeout, _onTimer);
  }

  void _onTimer(Timer timer) {
    Api.recentlyBlocked().then((String domain) {
      if (domains.length == 0 || domains.first != domain) {
        domains.insert(0, domain);
        setState(() {
          domains = domains;
          repeat = 0;
        });
      } else {
        setState(() {
          repeat = repeat + 1;
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
      domains = domains == null ? List() : domains;
      repeat = repeat;
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
    return ListView.builder(
        itemCount: domains.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              child: ListTile(
            title: Row(
              children: <Widget>[Text(domains[index]), Chip(label: Text('K'))],
            ),
          ));
        });
  }
}
