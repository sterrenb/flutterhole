import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TransparentAppBar extends HookWidget implements PreferredSizeWidget {
  const TransparentAppBar({
    Key? key,
    required this.controller,
    required this.title,
    this.actions,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  final Widget title;
  final ScrollController controller;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scrollPosition = useState(1.0);

    useEffect(() {
      controller.addListener(() {
        scrollPosition.value =
            (1 - controller.position.pixels / kToolbarHeight).clamp(0, 1);
      });
    }, [controller]);

    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      title: AnimatedOpacity(
        duration: kThemeAnimationDuration,
        opacity: scrollPosition.value > 0.4 ? 1 : 0,
        child: title,
      ),
      actions: actions,
    );
  }
}
