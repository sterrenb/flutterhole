import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/logging/log_widgets.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const double kMinTileHeight = 200.0;

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
      style: const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class TextTileContent extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final IconData iconData;
  final double iconLeft;
  final double? iconTop;
  final Color? foregroundColor;

  const TextTileContent({
    Key? key,
    required this.top,
    required this.bottom,
    required this.iconData,
    this.iconLeft = 16.0,
    this.iconTop,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned(
          left: iconLeft,
          top: iconTop,
          child: GridIcon(iconData),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: top,
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

class DashboardListIcon extends StatelessWidget {
  const DashboardListIcon(
    this.primaryIcon, {
    Key? key,
  }) : super(key: key);

  final IconData primaryIcon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      primaryIcon,
      size: 32.0,
      color: Colors.white.withOpacity(0.5),
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
          duration: const Duration(seconds: 1),
        ));
      },
    );
  }
}

class TopPermittedDomainsTile extends HookWidget {
  const TopPermittedDomainsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topItems = useProvider(activeTopItemsProvider);
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
            ListTile(
              // tileColor: Colors.green.withOpacity(0.1),
              title: const TileTitle(
                'Permitted Domains',
              ),
              leading: const GridIcon(
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
              loading: () => const SizedBox(
                  height: kMinTileHeight,
                  child: Center(child: CircularProgressIndicator())),
              error: (error, stacktrace) => Column(
                children: [
                  ListTile(
                    title: ExpandableCode(
                      code: error.toString(),
                      tappable: false,
                    ),
                  ),
                  ExpandableCode(
                    code: stacktrace.toString(),
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
  const TopBlockedDomainsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topItems = useProvider(activeTopItemsProvider);
    final expanded = useState(false);
    final ticker = useSingleTickerProvider();
    // return Card(
    //   child: Center(child: Text('hi')),
    // );

    return Card(
      child: AnimatedSize(
        vsync: ticker,
        duration: kThemeAnimationDuration * 2,
        alignment: Alignment.topCenter,
        curve: Curves.ease,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              // color: Colors.orange,
              height: 80,
              child: ListTile(
                // tileColor: Colors.red.withOpacity(0.1),
                title: const TileTitle('Blocked Domains'),
                leading: const GridIcon(
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
              loading: () => const SizedBox(
                  height: kToolbarHeight * 5,
                  child: Center(child: CircularProgressIndicator())),
              error: (error, stacktrace) =>
                  ExpandableCode(code: stacktrace.toString()),
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

// var index = 0;

class LogsTile extends HookWidget {
  const LogsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridCard(
      child: Column(
        children: [
          const ListTile(title: TileTitle('Logs')),
          const Expanded(
            child: AnimatedLogsList(
              maxLength: kLogsDashboardCacheLength,
              shrinkWrap: true,
              singleLine: true,
            ),
          ),
          ListTile(
            leading: const AddLogTextButton(),
            trailing: TextButton(
              child: HookBuilder(
                builder: (context) {
                  final records = useProvider(logNotifierProvider);
                  return Text(
                      'View ${numberFormat.format(records.length)} logs');
                },
              ),
              // child: Text('View ${numberFormat.format(records.length)} logs'),
              onPressed: () {
                context.router.push(const LogsRoute());
              },
            ),
          ),
        ],
      ),
    );
  }
}
