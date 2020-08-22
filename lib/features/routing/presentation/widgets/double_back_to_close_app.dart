import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/notifications/toasts.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Duration kDoubleBackToCloseDuration = Duration(seconds: 2);

class DoubleBackToCloseApp extends StatefulWidget {
  DoubleBackToCloseApp({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _DoubleBackToCloseAppState createState() => _DoubleBackToCloseAppState();
}

class _DoubleBackToCloseAppState extends State<DoubleBackToCloseApp> {
  Stopwatch _stopwatch;

  @override
  void dispose() {
    _stopwatch?.stop();
    super.dispose();
  }

  bool get _willHandlePopInternally =>
      ModalRoute.of(context).willHandlePopInternally;

  bool get _isDoubleBack {
    return _stopwatch?.isRunning ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDoubleBack || _willHandlePopInternally) {
          cancelToast();
          return true;
        }

        Fluttertoast.showToast(msg: 'Press BACK again to exit');

//        showToast('Press BACK again to exit');

        setState(() {
          _stopwatch = clock.stopwatch()..start();
        });

        Future.delayed(kDoubleBackToCloseDuration).then((_) {
          setState(() {
            _stopwatch?.stop();
            _stopwatch?.reset();
          });
        });

        return false;
      },
      child: widget.child,
    );
  }
}
