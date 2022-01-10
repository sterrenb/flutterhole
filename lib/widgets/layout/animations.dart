import 'package:flutter/material.dart';

class AnimatedFader extends StatelessWidget {
  const AnimatedFader({
    Key? key,
    required this.child,
    this.layoutBuilder = AnimatedFader.startLayoutBuilder,
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

  static Widget centerExpandLayoutBuilder(
      Widget? currentChild, List<Widget> previousChildren) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
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

class DefaultAnimatedSize extends StatelessWidget {
  const DefaultAnimatedSize({
    Key? key,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key);

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: alignment,
      duration: kThemeAnimationDuration,
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

class DefaultAnimatedOpacity extends StatelessWidget {
  const DefaultAnimatedOpacity({
    Key? key,
    required this.show,
    required this.child,
    this.hideOpacity = 0.0,
  }) : super(key: key);

  final bool show;
  final Widget child;
  final double hideOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: kThemeAnimationDuration,
      curve: Curves.easeOutCubic,
      opacity: show ? 1.0 : hideOpacity,
      child: child,
    );
  }
}

class AnimatedStack extends StatelessWidget {
  const AnimatedStack({
    Key? key,
    required this.children,
    required this.active,
    this.alignment,
  }) : super(key: key);

  final List<Widget> children;
  final int active;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment ?? Alignment.center,
      children: List.generate(
          children.length,
          (index) => DefaultAnimatedOpacity(
              show: index == active, child: children.elementAt(index))),
    );
  }
}
