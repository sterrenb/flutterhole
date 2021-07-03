import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/about/app_version.dart';
import 'package:flutterhole_web/features/about/logo.dart';
import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/pi_builders.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _DrawerTile extends StatelessWidget {
  const _DrawerTile(
    this.title,
    this.iconData,
    this.info, {
    Key? key,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final PageRouteInfo info;

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    final currentRouteName = router.current.name;
    final isActive = currentRouteName == info.routeName;

    return Container(
      decoration: isActive
          ? BoxDecoration(color: Theme.of(context).accentColor.withOpacity(.2))
          : null,
      child: ListTile(
        title: Text(title),
        // subtitle: Text('${router.current.name == info.routeName}'),
        leading: Icon(iconData),
        // tileColor: isActive
        //     ? Theme.of(context).accentColor.withOpacity(.2)
        //     : null,
        onLongPress: () {},
        onTap: () {
          // return;
          // Navigator.of(context).pop();
          // router.replace(info);
          // router.popAndPush(info);
          // print(router.current.name);
          // print(info.routeName);

          if (router.current.name == info.routeName) {
            router.pop();
          } else {
            router.pop();
            if (info.routeName == HomeRoute.name) {
              router.popUntilRoot();
              return;
            }
            context.log(LogCall(
                source: 'drawer',
                level: LogLevel.debug,
                message: 'pushing ${info.routeName}'));
            router.push(info);
          }
        },
      ),
    );
  }
}

final _expandedProvider = StateProvider<bool>((_) => false);

class _DrawerMenu extends HookWidget {
  const _DrawerMenu({Key? key}) : super(key: key);

  // TODO not sure what causes the initial height in the list builder
  static const double _initialHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final expanded = useProvider(_expandedProvider);
    final all = useProvider(allPisProvider);

    final _op = AnimatedOpacity(
      duration: kThemeChangeDuration,
      curve: Curves.ease,
      // opacity: 1,
      opacity: expanded.state ? 1 : 0,
      child: Material(
        color: Theme.of(context).cardColor,
        child: PiListBuilder(
          controller: controller,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          onTap: (pi) {
            context.read(settingsNotifierProvider.notifier).activate(pi.id);
            context.router.pop();
          },
          // onLongPress: (pi) {
          //   context.router.pushAndSaveSinglePiRoute(context, pi);
          // },
        ),
      ),
    );

    // return _op;

    return AnimatedContainer(
      duration: kThemeChangeDuration,
      curve: Curves.ease,
      height: expanded.state ? (65 * all.length) + _initialHeight : 0,
      // height: expanded.state ? kToolbarHeight * 4 : 0,
      color: Theme.of(context).cardColor,
      child: _op,
    );
  }
}

class _DrawerHeader extends HookWidget {
  const _DrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expanded = useProvider(_expandedProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          expanded.state = !expanded.state;
        },
        child: UserAccountsDrawerHeader(
          accountName: Row(
            children: const [
              ActivePiTitle(),
              // PiStatusIndicator(enabled: false),
            ],
          ),
          // onDetailsPressed: () {
          //   expanded.state = !expanded.state;
          // },
          arrowColor: Theme.of(context).colorScheme.onPrimary,
          accountEmail: null,
          margin: EdgeInsets.zero,
          currentAccountPicture: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FlutterHole',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              PackageVersionText(
                includeBuild: false,
                textStyle: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          ),
          otherAccountsPictures: null,
        ),
      ),
    );
  }
}

class AppDrawer extends HookWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        // alignment: Alignment.centerLeft,
        alignment: Alignment.bottomCenter,
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: const [
              _DrawerHeader(),
              _DrawerMenu(),
              _DrawerTile(
                'Dashboard',
                KIcons.dashboard,
                HomeRoute(),
              ),
              _DrawerTile(
                'Query Log',
                KIcons.queryLog,
                QueryLogRoute(),
              ),
              Divider(),
              _DrawerTile(
                'About',
                KIcons.about,
                AboutRoute(),
              ),
              _DrawerTile(
                'Settings',
                KIcons.settings,
                SettingsRoute(),
              ),
            ],
          ),
          HookBuilder(
            builder: (context) {
              final expanded = useProvider(_expandedProvider);
              return AnimatedOpacity(
                duration: kThemeChangeDuration,
                curve: Curves.ease,
                opacity: expanded.state ? 0 : 0.1,
                child: const ThemedLogoImage(
                  width: 150.0,
                  height: 150.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
