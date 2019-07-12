import 'package:flutter/material.dart';

class CircularPercentageIndicator extends StatefulWidget {
  /// The duration of a full animation
  final Duration duration;

  /// The starting point for the animation, from 0.0 to 1.0
  final double start;

  final Color color;

  const CircularPercentageIndicator({Key key,
    @required this.duration,
    @required this.start,
    @required this.color})
      : super(key: key);

  @override
  _CircularPercentageIndicatorState createState() =>
      new _CircularPercentageIndicatorState();
}

class _CircularPercentageIndicatorState
    extends State<CircularPercentageIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = Tween(begin: 1.0 - widget.start, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
      child: CircularProgressIndicator(
        value: animation.value,
        strokeWidth: 2.0,
        valueColor: new AlwaysStoppedAnimation<Color>(widget.color),
      ),
    ));
  }
}
