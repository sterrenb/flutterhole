import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';

const Duration kDoubleBackToCloseDuration = Duration(seconds: 2);

class DoubleBackToCloseApp extends StatefulWidget {
  DoubleBackToCloseApp({
    Key? key,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  final Widget child;
  final bool enabled;

  @override
  _DoubleBackToCloseAppState createState() => _DoubleBackToCloseAppState();
}

class _DoubleBackToCloseAppState extends State<DoubleBackToCloseApp> {
  Stopwatch stopwatch = Stopwatch();

  @override
  void dispose() {
    stopwatch.stop();
    super.dispose();
  }

  bool get _willHandlePopInternally =>
      ModalRoute.of(context)?.willHandlePopInternally ?? true;

  bool get _isDoubleBack {
    return stopwatch.isRunning;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return WillPopScope(
      onWillPop: () async {
        if (_isDoubleBack || _willHandlePopInternally) {
          ScaffoldMessenger.of(context).clearSnackBars();
          return true;
        }

        ScaffoldMessenger.of(context)
            .showThemedMessageNow(context, message: 'Press BACK again to exit');

        setState(() {
          stopwatch = clock.stopwatch()..start();
        });

        Future.delayed(kDoubleBackToCloseDuration).then((_) {
          setState(() {
            stopwatch.stop();
            stopwatch.reset();
          });
        });

        return false;
      },
      child: widget.child,
    );
  }
}
