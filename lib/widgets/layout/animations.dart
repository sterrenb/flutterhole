import 'package:flutter/material.dart';

class AnimatedFader extends StatelessWidget {
  const AnimatedFader({
    Key? key,
    required this.child,
    this.layoutBuilder = startLayoutBuilder,
    this.duration = kThemeAnimationDuration,
  }) : super(key: key);

  final Widget child;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;
  final Duration duration;

  static Widget startLayoutBuilder(
      Widget? currentChild, List<Widget> previousChildren) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: child,
      layoutBuilder: layoutBuilder,
    );
  }
}

class AnimatedColorFader extends StatelessWidget {
  const AnimatedColorFader({
    Key? key,
    required this.show,
    this.child = const Text(''),
    this.color,
    this.centerChild = true,
  }) : super(key: key);

  final bool show;
  final Widget? child;
  final Color? color;
  final bool centerChild;

  @override
  Widget build(BuildContext context) {
    return AnimatedFader(
      duration: kThemeAnimationDuration * 2,
      child: show
          ? Container(
              color: color ?? Theme.of(context).scaffoldBackgroundColor,
              child: centerChild ? Center(child: child) : child,
            )
          : Center(child: Container(child: child)),
    );
  }
}
