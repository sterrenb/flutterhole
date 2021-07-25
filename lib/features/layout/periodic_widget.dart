import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef PeriodicCallback = void Function(Timer timer);

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

class PerHookWidget extends HookWidget {
  const PerHookWidget({
    Key? key,
    required this.child,
    required this.onTimer,
  }) : super(key: key);

  final Widget child;
  final PeriodicCallback onTimer;

  @override
  Widget build(BuildContext context) {
    final prefs = useProvider(userPreferencesProvider);
    final timer = useState(
        Timer.periodic(const Duration(seconds: 2), (timer) {})..cancel());

    useEffect(() {
      if (prefs.updateFrequency > Duration.zero) {
        final newTimer = Timer.periodic(prefs.updateFrequency, onTimer);
        timer.value = newTimer;
        return newTimer.cancel;
      }
    }, [prefs.updateFrequency]);
    return child;
  }
}
