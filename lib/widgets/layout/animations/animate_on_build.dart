import 'package:flutter/material.dart';

class AnimateOnBuild extends StatefulWidget {
  const AnimateOnBuild({
    Key key,
    @required this.child,
    this.duration = kThemeAnimationDuration,
  }) : super(key: key);

  final Widget child;
  final Duration duration;

  @override
  _AnimateOnBuildState createState() => _AnimateOnBuildState();
}

class _AnimateOnBuildState extends State<AnimateOnBuild> {
  double opacity;

  @override
  void initState() {
    super.initState();
    opacity = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(widget.duration).then((_) {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.duration,
      child: widget.child,
    );
  }
}
