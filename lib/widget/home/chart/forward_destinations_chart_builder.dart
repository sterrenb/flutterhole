import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/forward_destinations.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/forward_destinations.dart';
import 'package:flutterhole/widget/home/chart/indicator.dart';
import 'package:flutterhole/widget/home/chart/pi_chart.dart';
import 'package:flutterhole/widget/layout/error_message.dart';

class ForwardDestinationsChartBuilder extends StatelessWidget {
  static final _colors = [
    Colors.green,
    Colors.cyan,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.indigo,
    Colors.blue,
  ];

  MaterialColor _color(int index) => _colors[index % _colors.length];

  List<PieChartSectionData> _sectionsFromForwardDestinations(
      ForwardDestinations forwardDestinations, double width) {
    List<PieChartSectionData> items = [];

    int index = 0;
    forwardDestinations.items.forEach((ForwardDestinationItem item) {
      double value = item.percent;

      items.add(PieChartSectionData(
          title: value > 5.0 ? '${value.floor().toString()}%' : '',
          value: value,
          color: _color(index),
          radius: width));
      index++;
    });

    return items;
  }

  List<Indicator> _indicatorsFromForwardDestinations(
      BuildContext context, ForwardDestinations forwardDestinations) {
    List<Indicator> indicators = [];
    int index = 0;
    forwardDestinations.items.forEach((ForwardDestinationItem item) {
      indicators.add(Indicator(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(item.title)),
                Text(
                  '${item.percent.toString()}%',
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption,
                )
              ],
            ),
            item.title == item.ipString
                ? Container()
                : Text(
              item.ipString,
              style: Theme
                  .of(context)
                  .textTheme
                  .caption,
            ),
          ],
        ),
        color: _color(index),
      ));
      index++;
    });

    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    final ForwardDestinationsBloc forwardDestinationsBloc =
        BlocProvider.of<ForwardDestinationsBloc>(context);
    return BlocBuilder(
      bloc: forwardDestinationsBloc,
      builder: (context, state) {
        if (state is BlocStateSuccess<ForwardDestinations>) {
          final screenWidth = MediaQuery.of(context).size.width;
          return PiChart(
            title: 'Forward destinations',
            centerSpaceRadius: screenWidth / 8,
            sections: _sectionsFromForwardDestinations(state.data, 50),
            indicators: _indicatorsFromForwardDestinations(context, state.data),
          );
        }
        if (state is BlocStateError<ForwardDestinations>) {
          return ErrorMessage(errorMessage: state.e.message);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
