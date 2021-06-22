import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ListTitle extends StatelessWidget {
  const ListTitle(
    this.message, {
    Key? key,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: Theme.of(context).accentColor),
      ),
    );
  }
}

class OverScrollMessage extends HookWidget {
  const OverScrollMessage({
    Key? key,
    required this.controller,
    required this.height,
    required this.child,
    this.threshold = -1.0,
  }) : super(key: key);

  final ScrollController controller;
  final double height;
  final Widget child;
  final double threshold;

  static const double min = 0.0;
  static const double max = 1.0;

  @override
  Widget build(BuildContext context) {
    final scrollPosition = useState(1.0);

    useEffect(() {
      controller.addListener(() {
        // print(controller.position.pixels / height);
        scrollPosition.value =
            (controller.position.pixels / height); // .clamp(-1, 0);
      });
    }, [controller]);

    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        duration: kThemeAnimationDuration,
        opacity: scrollPosition.value <= threshold ? max : min,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                // color: Colors.blueGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedListTile extends StatelessWidget {
  const AnimatedListTile({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation1 = animation.drive(CurveTween(curve: Curves.easeInOut));
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation1,
      // axisAlignment: 1.0,
      child: FadeTransition(
        opacity: animation1,
        child: child,
      ),
    );
  }
}
