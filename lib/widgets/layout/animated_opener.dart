import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class AnimatedOpener extends StatelessWidget {
  const AnimatedOpener({
    Key key,
    @required this.closed,
    @required this.opened,
    this.onLongPress,
  }) : super(key: key);

  final WidgetBuilder closed;
  final WidgetBuilder opened;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Theme.of(context).scaffoldBackgroundColor,
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      closedShape: ContinuousRectangleBorder(),
      closedBuilder: (
        BuildContext context,
        VoidCallback openContainer,
      ) {
        return Material(
          child: InkWell(
            onTap: openContainer,
            onLongPress: onLongPress,
            child: closed(context),
          ),
        );
      },
      openBuilder: (
        BuildContext context,
        VoidCallback closeContainer,
      ) {
        return opened(context);
      },
    );
  }
}
