import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const Duration kPeriodicInterval = Duration(seconds: 10);

class PeriodicWidget extends StatefulWidget {
  final Widget? child;
  final WidgetBuilder? builder;
  final Duration interval;
  final ValueChanged<Timer> onTimer;

  const PeriodicWidget({
    Key? key,
    this.child,
    this.builder,
    this.interval = kPeriodicInterval,
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
      widget.interval,
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

class PerHookWidget extends HookConsumerWidget {
  const PerHookWidget({
    Key? key,
    required this.interval,
    required this.child,
    required this.onTimer,
  }) : super(key: key);

  final Duration interval;
  final Widget child;
  final ValueChanged<Timer> onTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = useState(
        Timer.periodic(const Duration(seconds: 2), (timer) {})..cancel());

    useEffect(() {
      if (interval > Duration.zero) {
        final newTimer = Timer.periodic(interval, onTimer);
        timer.value = newTimer;
        return newTimer.cancel;
      }
    }, [interval]);
    return child;
  }
}
