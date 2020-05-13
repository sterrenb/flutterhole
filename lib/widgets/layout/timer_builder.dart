import 'dart:async';

import 'package:flutter/widgets.dart';

const Duration kTimerBuilderDuration = Duration(seconds: 10);

/// Rebuilds [builder] periodically every [duration].
class TimerBuilder extends StatefulWidget {
  const TimerBuilder({
    Key key,
    @required this.builder,
    this.duration = kTimerBuilderDuration,
    this.onTick,
  }) : super(key: key);

  final WidgetBuilder builder;
  final Duration duration;
  final VoidCallback onTick;

  @override
  _TimerBuilderState createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {
        if (widget.onTick != null) widget.onTick();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
