import 'package:flutter/material.dart';

class AnimatedFader extends StatelessWidget {
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

  const AnimatedFader({
    Key? key,
    required this.child,
    this.layoutBuilder = startLayoutBuilder,
  }) : super(key: key);

  final Widget child;

  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: child,
      layoutBuilder: layoutBuilder,
    );
  }
}
