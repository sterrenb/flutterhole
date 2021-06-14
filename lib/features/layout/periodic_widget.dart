import 'dart:async';

import 'package:flutter/material.dart';

typedef void PeriodicCallback(Timer timer);

class PeriodicWidget extends StatefulWidget {
  final Widget? child;
  final WidgetBuilder? builder;
  final Duration duration;
  final PeriodicCallback onTimer;

  const PeriodicWidget({
    Key? key,
    this.child,
    this.builder,
    required this.duration,
    required this.onTimer,
  })  : assert(builder == null || child == null),
        super(key: key);

  @override
  _PeriodicWidgetState createState() => _PeriodicWidgetState();
}

class _PeriodicWidgetState extends State<PeriodicWidget> {
  Timer? timer;
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
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.child == null ? widget.builder!(context) : widget.child!;
}
