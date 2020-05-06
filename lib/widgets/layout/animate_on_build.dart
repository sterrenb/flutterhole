import 'package:flutter/material.dart';

class AnimateOnBuild extends StatefulWidget {
  const AnimateOnBuild({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

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
    Future.delayed(kThemeAnimationDuration).then((_) {
      setState(() {
        opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: kThemeAnimationDuration,
      child: widget.child,
    );
  }
}
