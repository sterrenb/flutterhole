import 'dart:ui';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat();

const double kMinTileHeight = 150.0;

class TextTileBottomText extends StatelessWidget {
  const TextTileBottomText(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class TextTileContent extends StatelessWidget {
  final String top;
  final Widget bottom;
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
          child: DashboardTileIcon(iconData),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: TileTitle(top),
            ),
            Center(
              child: bottom,
            ),
          ],
        ),
      ],
    );
  }
}

class TileTitle extends StatelessWidget {
  const TileTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }
}

class DashboardTileIcon extends StatelessWidget {
  const DashboardTileIcon(
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
    final option = useProvider(sumCacheProvider).state;

    return Card(
      color: KColors.totalQueries,
      child: InkWell(
        onTap: () {
          option.fold(
            () {},
            (piSummary) => showOkAlertDialog(
              context: context,
              message: piSummary.toString(),
            ),
          );
        },
        child: TextTileContent(
          top: 'Total Queries',
          bottom: TextTileBottomText(option.fold(
            () => '---',
            (piSummary) => _numberFormat.format(piSummary.dnsQueriesToday),
          )),
          iconData: KIcons.totalQueries,
        ),
      ),
    );
  }
}

class QueriesBlockedTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final option = useProvider(sumCacheProvider).state;
    return Card(
      color: KColors.queriesBlocked,
      child: InkWell(
        onTap: () {
          option.fold(
              () => null,
              (a) => showOkAlertDialog(
                    context: context,
                    message: a.toString(),
                  ));
        },
        child: TextTileContent(
          top: 'Queries Blocked',
          bottom: TextTileBottomText(option.fold(
            () => '---',
            (piSummary) => _numberFormat.format(piSummary.adsBlockedToday),
          )),
          iconData: KIcons.queriesBlocked,
        ),
      ),
    );
  }
}

class PercentBlockedTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final option = useProvider(sumCacheProvider).state;
    return Card(
      color: KColors.percentBlocked,
      child: InkWell(
        onTap: () {
          option.fold(
            () {},
            (piSummary) => showOkAlertDialog(
              context: context,
              message: piSummary.toString(),
            ),
          );
        },
        child: TextTileContent(
          top: 'Percent Blocked',
          bottom: TextTileBottomText(option.fold(
            () => '---',
            (piSummary) =>
                '${piSummary.adsPercentageToday.toStringAsFixed(2)}%',
          )),
          iconData: KIcons.percentBlocked,
        ),
      ),
    );
  }
}

class DomainsOnBlocklistTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final option = useProvider(sumCacheProvider).state;
    return Card(
      color: KColors.domainsOnBlocklist,
      child: InkWell(
        onTap: () {
          option.fold(
            () {},
            (piSummary) => showOkAlertDialog(
              context: context,
              message: piSummary.toString(),
            ),
          );
        },
        child: TextTileContent(
          top: 'Domains on Blocklist',
          bottom: TextTileBottomText(option.fold(
            () => '---',
            (piSummary) => _numberFormat.format(piSummary.domainsBeingBlocked),
          )),
          iconData: KIcons.domainsOnBlocklist,
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
    final pi = useProvider(activePiProvider).state;
    final topItems = useProvider(topItemsProvider(pi));
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
              title: TileTitle(
                'Permitted Domains',
              ),
              leading: DashboardTileIcon(
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
    final pi = useProvider(activePiProvider).state;
    final topItems = useProvider(topItemsProvider(pi));
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
                title: TileTitle(
                  'Blocked Domains',
                ),
                leading: DashboardTileIcon(
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
