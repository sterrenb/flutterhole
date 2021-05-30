import 'dart:ui';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat();

class TextTileContent extends StatelessWidget {
  final String top;
  final String bottom;
  final IconData iconData;
  final double iconLeft;
  final double? iconTop;

  const TextTileContent({
    Key? key,
    required this.top,
    required this.bottom,
    required this.iconData,
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
          child: _TileIcon(iconData),
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

class _TileIcon extends StatelessWidget {
  const _TileIcon(
    this.primaryIcon, {
    Key? key,
    this.subIcon,
    this.subIconColor,
  }) : super(key: key);

  final IconData primaryIcon;
  final IconData? subIcon;
  final Color? subIconColor;

  @override
  Widget build(BuildContext context) {
    final primary = Icon(
      primaryIcon,
      size: 32.0,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    );

    if (subIcon != null) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          primary,
          Positioned(
              left: 18.0,
              top: 18.0,
              child: Container(
                // color: Colors.purple,
                child: Icon(
                  subIcon,
                  size: 24.0,
                  color: subIconColor,
                ),
              )),
        ],
      );
    }
    return primary;
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
            data: (summary) => showOkAlertDialog(
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
            data: (summary) => showOkAlertDialog(
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
            data: (summary) => showOkAlertDialog(
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
      color: Colors.red,
      child: InkWell(
        onTap: () {
          summary.maybeWhen(
            data: (summary) => showOkAlertDialog(
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
          bottom: option.fold(() => '---', (details) {
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
      color: Colors.blueGrey,
      // color: Colors.grey[800],
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

class _QueryItemDivider extends StatelessWidget {
  const _QueryItemDivider({
    Key? key,
    this.color,
  }) : super(key: key);

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      indent: 16.0,
      endIndent: 16.0,
      color: color,
    );
  }
}

class _QueryItemTile extends StatelessWidget {
  const _QueryItemTile(
    this.entry, {
    Key? key,
  }) : super(key: key);

  final MapEntry<String, int> entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        entry.key,
        // maxLines: 1,
      ),
      trailing: Text(entry.value.toString()),
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: Text(
            '${entry.key}: ${entry.value} requests',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          duration: Duration(seconds: 1),
        ));
      },
    );
  }
}

class TopPermittedDomainsTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final topItems = useProvider(topItemsProvider);
    final expanded = useState(false);
    final ticker = useSingleTickerProvider();
    return Card(
      // color: Colors.blueGrey,
      child: AnimatedSize(
        vsync: ticker,
        duration: kThemeAnimationDuration * 2,
        alignment: Alignment.topCenter,
        curve: Curves.ease,
        child: Column(
          children: [
            ListTile(
              // tileColor: Colors.green.withOpacity(0.1),
              title: Text(
                'Permitted Domains',
                textAlign: TextAlign.center,
              ),
              leading: _TileIcon(
                KIcons.domainsPermittedTile,
                subIcon: Icons.check_box,
                subIconColor: Colors.green,
              ),
              onTap: topItems.maybeWhen(
                data: (_) => () {
                  expanded.value = !expanded.value;
                },
                orElse: () => null,
              ),
              trailing: Icon(expanded.value ? KIcons.shrink : KIcons.expand),
            ),
            topItems.when(
              data: (topItems) {
                return ListView.separated(
                  itemCount: expanded.value ? topItems.topQueries.length : 3,
                  shrinkWrap: true,
                  primary: false,
                  separatorBuilder: (context, index) => const _QueryItemDivider(
                    color: Colors.green,
                  ),
                  itemBuilder: (context, index) {
                    final entry = topItems.topQueries.entries.elementAt(index);
                    return _QueryItemTile(entry);
                  },
                );
              },
              loading: () => Container(
                  height: kToolbarHeight * 3,
                  child: Center(child: CircularProgressIndicator())),
              error: (error, stacktrace) => Column(
                children: [
                  ListTile(
                    title: CodeCard(
                      error.toString(),
                      tappable: false,
                    ),
                  ),
                  CodeCard(
                    stacktrace.toString(),
                    // tappable: false,
                  ),
                ],
              ),
            ),
            Container(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }
}

class TopBlockedDomainsTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final topItems = useProvider(topItemsProvider);
    final expanded = useState(false);
    final ticker = useSingleTickerProvider();
    return Card(
      child: AnimatedSize(
        vsync: ticker,
        duration: kThemeAnimationDuration * 2,
        alignment: Alignment.topCenter,
        curve: Curves.ease,
        child: Column(
          children: [
            Container(
              // color: Colors.orange,
              child: ListTile(
                // tileColor: Colors.red.withOpacity(0.1),
                title: Text(
                  'Blocked Domains',
                  textAlign: TextAlign.center,
                ),
                leading: _TileIcon(
                  KIcons.domainsPermittedTile,
                  subIcon: Icons.remove_circle,
                  subIconColor: Colors.red,
                ),
                onTap: topItems.maybeWhen(
                  data: (_) => () {
                    expanded.value = !expanded.value;
                  },
                  orElse: () => null,
                ),
                trailing: Icon(expanded.value ? KIcons.shrink : KIcons.expand),
              ),
            ),
            topItems.when(
              data: (topItems) {
                return ListView.separated(
                  itemCount: expanded.value ? topItems.topAds.length : 3,
                  shrinkWrap: true,
                  primary: false,
                  separatorBuilder: (context, index) =>
                      const _QueryItemDivider(color: Colors.red),
                  itemBuilder: (context, index) {
                    final entry = topItems.topAds.entries.elementAt(index);
                    return _QueryItemTile(entry);
                  },
                );
              },
              loading: () => Container(
                  height: kToolbarHeight * 3,
                  child: Center(child: CircularProgressIndicator())),
              error: (error, stacktrace) => CodeCard(stacktrace.toString()),
            ),
            Container(
              height: 5.0,
            ),
          ],
        ),
      ),
    );
  }
}
