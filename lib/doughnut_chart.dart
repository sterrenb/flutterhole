import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/layout/grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const double kShowTitleThresholdPercentage = 105.0;

class DoughnutChartData {
  DoughnutChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

class DoughnutScaffold extends StatelessWidget {
  const DoughnutScaffold({
    Key? key,
    required this.left,
    required this.right,
  }) : super(key: key);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: left,
          ),
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: right,
          ),
        ],
      ),
    );
  }
}

final doughnutChartProvider =
    StateProvider.family<String, String>((ref, title) => '');

class DoughnutChart extends HookWidget {
  const DoughnutChart({
    Key? key,
    required this.title,
    required this.dataSource,
  }) : super(key: key);

  final String title;
  final List<DoughnutChartData> dataSource;

  @override
  Widget build(BuildContext context) {
    final selected = useProvider(doughnutChartProvider(title));
    return Container(
      child: PieChart(PieChartData(
        startDegreeOffset: 270,
        borderData: FlBorderData(show: false),
        pieTouchData:
            PieTouchData(touchCallback: (PieTouchResponse pieTouchResponse) {
          final desiredTouch =
              pieTouchResponse.touchInput is! PointerExitEvent &&
                  pieTouchResponse.touchInput is! PointerUpEvent;
          if (desiredTouch && pieTouchResponse.touchedSection != null) {
            final index = pieTouchResponse.touchedSection!.touchedSectionIndex;
            if (index >= 0) {
              selected.state = dataSource.elementAt(index).x;
              return;
            }
          }
          selected.state = '';
        }),
        sectionsSpace: selected.state.isNotEmpty ? 4.0 : 2.0,
        sections: dataSource
            .map((data) => PieChartSectionData(
                  title: '${data.y.toStringAsFixed(0)}%',
                  value: data.y,
                  color: data.color,
                  showTitle: data.y >= kShowTitleThresholdPercentage,
                  radius: selected.state == data.x ? 45 : 40,
                ))
            .toList(),
      )),
    );
  }
}

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

class LegendTileList extends StatelessWidget {
  const LegendTileList({
    Key? key,
    required this.title,
    required this.legendTiles,
  }) : super(key: key);

  final String title;
  final List<Widget> legendTiles;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Center(child: TileTitle(title)),
          ),
          ...legendTiles,
        ],
      ),
    );
  }
}

class DoughnutChartLegendList extends StatelessWidget {
  const DoughnutChartLegendList({
    Key? key,
    required this.title,
    required this.iconData,
    required this.builder,
    required this.childCount,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final IndexedWidgetBuilder builder;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListTile(
            title: TileTitle(title),
            // horizontalTitleGap: 0.0,
            // leading: Container(
            //   child: DashboardTileIcon(iconData),
            //   // color: Colors.orangeAccent,
            // ),
          ),
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
