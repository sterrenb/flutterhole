import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final _numberFormat = NumberFormat();

class TextTileContent extends StatelessWidget {
  final String top;
  final String bottom;
  final IconData iconData;
  final double iconLeft;
  final double iconTop;

  const TextTileContent({
    Key key,
    @required this.top,
    @required this.bottom,
    @required this.iconData,
    this.iconLeft = 16.0,
    this.iconTop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned(
          left: iconLeft,
          top: iconTop,
          child: Icon(
            iconData,
            size: 32.0,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                top,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                bottom,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TotalQueriesTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.green,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) =>
                showOkAlertDialog(
                  context: context,
                  message: summary.toString(),
                ),
            error: (e, s) => showErrorDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Total Queries',
          bottom: summary.when(
            data: (summary) => _numberFormat.format(summary.dnsQueriesToday),
            loading: () => '',
            error: (e, s) => '---',
          ),
          iconData: KIcons.totalQueries,
        ),
      ),
    );
  }
}

class QueriesBlockedTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.lightBlue,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) =>
                showOkAlertDialog(
                  context: context,
                  message: summary.toString(),
                ),
            error: (e, s) => showErrorDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Queries Blocked',
          bottom: summary.when(
            data: (summary) => _numberFormat.format(summary.adsBlockedToday),
            loading: () => '',
            error: (e, s) => '---',
          ),
          iconData: KIcons.queriesBlocked,
        ),
      ),
    );
  }
}

class PercentBlockedTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.orange,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) =>
                showOkAlertDialog(
                  context: context,
                  message: summary.toString(),
                ),
            error: (e, s) => showErrorDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Percent Blocked',
          bottom: summary.when(
            data: (summary) =>
            '${summary.adsPercentageToday.toStringAsFixed(2)}%',
            loading: () => '',
            error: (e, s) => '---',
          ),
          iconData: KIcons.percentBlocked,
        ),
      ),
    );
  }
}

class DomainsOnBlocklistTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final summary = useProvider(summaryProvider);
    return Card(
      color: Colors.redAccent,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) =>
                showOkAlertDialog(
                  context: context,
                  message: summary.toString(),
                ),
            error: (e, s) => showErrorDialog(context, e, s),
            orElse: () {},
          );
        },
        child: TextTileContent(
          top: 'Domains on Blocklist',
          bottom: summary.when(
            data: (summary) =>
                _numberFormat.format(summary.domainsBeingBlocked),
            loading: () => '',
            error: (e, s) => '---',
          ),
          iconData: KIcons.domainsOnBlocklist,
        ),
      ),
    );
  }
}

class PiTemperatureTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final temperatureReading = useProvider(temperatureReadingProvider).state;
    final option = useProvider(piDetailsOptionProvider).state;
    return Card(
      color: Colors.orange,
      child: InkWell(
        onTap: () {},
        child: TextTileContent(
          top: 'Temperature',
          bottom: option.fold(() => '', (details) {
            switch (temperatureReading) {
              case TemperatureReading.celcius:
                return details.temperatureInCelcius;
              case TemperatureReading.fahrenheit:
                return details.temperatureInFahrenheit;
              case TemperatureReading.kelvin:
              default:
                return details.temperatureInKelvin;
            }
          }),
          iconData: KIcons.temperatureReading,
          iconTop: 16.0,
        ),
      ),
    );
  }
}

class PiMemoryTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final option = useProvider(piDetailsOptionProvider).state;
    return Card(
      color: Colors.grey[800],
      child: InkWell(
        onTap: () {},
        child: TextTileContent(
          top: 'Memory Usage',
          bottom: option.fold(() => '---', (details) {
            if (details.memoryUsage < 0) return '---';
            return '${details.memoryUsage.toStringAsFixed(1)}%';
          }),
          iconData: KIcons.memoryUsage,
          iconTop: 16.0,
        ),
      ),
    );
  }
}

