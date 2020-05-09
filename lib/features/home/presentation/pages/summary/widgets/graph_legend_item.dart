import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/notifiers/pie_chart_notifier.dart';
import 'package:provider/provider.dart';

class _LegendIndicator extends StatefulWidget {
  const _LegendIndicator({
    Key key,
    @required this.title,
    this.subtitle,
    this.color,
    this.isSquare = true,
    this.size = 12,
    this.textColor = const Color(0xff505050),
    this.selected,
  }) : super(key: key);

  final Color color;
  final Widget title;
  final Widget subtitle;
  final bool isSquare;
  final double size;
  final Color textColor;
  final bool selected;

  @override
  _LegendIndicatorState createState() => _LegendIndicatorState();
}

class _LegendIndicatorState extends State<_LegendIndicator>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Row(
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AnimatedSize(
          vsync: this,
          curve: Curves.easeInOut,
          duration: kThemeAnimationDuration,
          reverseDuration: kThemeAnimationDuration,
          child: Container(
            width: widget.selected ? widget.size / 2 : 0.0,
          ),
        ),
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape:
            widget.isSquare || false ? BoxShape.rectangle : BoxShape.circle,
            color: widget.color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        widget.title,
        widget.subtitle ?? Container(),
      ],
    );
  }
}

class GraphLegendItem extends StatelessWidget {
  const GraphLegendItem({
    Key key,
    @required this.title,
    @required this.index,
    this.subtitle,
    this.color,
  }) : super(key: key);
  final String title;
  final int index;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Consumer<PieChartNotifier>(
      builder: (BuildContext context, PieChartNotifier value, _) {
        return _LegendIndicator(
          selected: value?.selected == index,
//          size: value.selected == index ? 16.0 : 12.0,
          title: Expanded(
            child: Text(
              '$title',
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle1,
              maxLines: 1,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              '$subtitle',
              style: Theme
                  .of(context)
                  .textTheme
                  .caption,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          color: color,
          isSquare: false,
        );
      },
    );
  }
}
