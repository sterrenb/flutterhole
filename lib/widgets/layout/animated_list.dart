import 'package:flutter/material.dart';

class DefaultAnimatedSize extends StatelessWidget {
  const DefaultAnimatedSize({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = animation.drive(CurveTween(curve: Curves.easeInOut));
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: a,
      // axisAlignment: 1.0,
      child: FadeTransition(
        opacity: a,
        child: child,
      ),
    );
  }
}
