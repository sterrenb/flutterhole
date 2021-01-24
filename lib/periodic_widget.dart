import 'dart:async';

import 'package:flutter/material.dart';

typedef void PeriodicCallback(Timer timer);

class PeriodicWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final PeriodicCallback onTimer;

  const PeriodicWidget({
    Key key,
    @required this.child,
    @required this.duration,
    @required this.onTimer,
  }) : super(key: key);

  @override
  _PeriodicWidgetState createState() => _PeriodicWidgetState();
}

class _PeriodicWidgetState extends State<PeriodicWidget> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      widget.duration,
      widget.onTimer,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
