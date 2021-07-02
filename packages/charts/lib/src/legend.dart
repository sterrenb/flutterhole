import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LegendTile extends HookWidget {
  final String title;
  final String trailing;
  final bool selected;
  final Color color;

  const LegendTile({
    Key? key,
    required this.title,
    required this.trailing,
    required this.selected,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    return InkWell(
      // onLongPress: () {},
      onTap: () {
        expanded.value = !expanded.value;
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          left: 16.0,
          right: 4.0,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: kThemeAnimationDuration,
              curve: Curves.easeIn,
              width: selected ? 5 : 0,
            ),
            Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            SizedBox(width: 8.0),
            Expanded(child: Text(title, maxLines: expanded.value ? null : 1)),
            Text(
              trailing,
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(width: 4.0),
          ],
        ),
      ),
    );
  }
}

class LegendList extends StatelessWidget {
  const LegendList({
    Key? key,
    required this.title,
    required this.iconData,
    required this.builder,
    required this.childCount,
  }) : super(key: key);

  final Widget title;
  final IconData iconData;
  final IndexedWidgetBuilder builder;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: title,
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
          builder,
          childCount: childCount,
        )),
      ],
    );
  }
}
