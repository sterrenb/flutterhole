import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/widgets/layout/animated_list.dart';

class AnimatedDemoLogList extends HookWidget {
  const AnimatedDemoLogList({
    Key? key,
  }) : super(key: key);

  static final Duration duration = kThemeAnimationDuration * 3;

  @override
  Widget build(BuildContext context) {
    final list = useState([20, 50, 100]);
    final k = useState(GlobalKey<AnimatedListState>()).value;

    void deleteAtIndex(int index) {
      final id = list.value.elementAt(index);
      list.value = [...list.value..removeAt(index)];
      k.currentState?.removeItem(
          index, (context, animation) => _DemoLogTile(id, animation),
          duration: duration);

      list.value = [
        Random().nextInt(80) + 30,
        ...list.value,
      ];
      k.currentState?.insertItem(0, duration: duration);
    }

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        deleteAtIndex(list.value.length - 1);
      });

      return timer.cancel;
    }, const []);

    return AnimatedList(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      key: k,
      initialItemCount: list.value.length,
      itemBuilder: (context, index, animation) {
        return _DemoLogTile(list.value.elementAt(index), animation);
      },
    );
  }
}

class _DemoLogTile extends HookWidget {
  const _DemoLogTile(
    this.id,
    this.animation, {
    Key? key,
  }) : super(key: key);

  final int id;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final titleColor = useMemoized(() {
      if (Random(id * 2).nextDouble() > .4) return Colors.red;
      return Theme.of(context).colorScheme.onSurface;
    }, [id]);

    return AnimatedListTile(
      animation: animation,
      child: ListTile(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Card(
                  color: titleColor,
                  child: SizedBox(
                    height: Theme.of(context).textTheme.headline6!.fontSize,
                    width: constraints.maxWidth * (id / 120),
                  ),
                ),
              ],
            );
          },
        ),
        subtitle: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.onSurface,
                  child: SizedBox(
                    height: Theme.of(context).textTheme.bodyText2!.fontSize,
                    width: constraints.maxWidth * ((id / 200) + .4),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
