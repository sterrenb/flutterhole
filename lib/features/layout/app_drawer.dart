import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _PiAvatar extends StatelessWidget {
  const _PiAvatar({
    Key? key,
    required this.pi,
    required this.onTap,
  }) : super(key: key);

  final Pi pi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CircleAvatar(
          child: Text(String.fromCharCode(pi.title.runes.first)),
          backgroundColor: pi.primaryColor,
        ),
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: Tooltip(
              message: pi.title,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
        onTap: () {
          // return;
          // Navigator.of(context).pop();
          // router.replace(info);
          // router.popAndPush(info);
          // print(router.current.name);
          // print(info.routeName);

          if (router.current.name == info.routeName) {
            print('popping');
            router.pop();
          } else {
            router.pop();
            if (info.routeName == HomeRoute.name) {
              print('popping to home');
              router.popUntilRoot();
              return;
            }
            print('pushing ${info.routeName}');
            router.push(info);
          }

          return;

          // Navigator.of(context).pop();
          // if (isActive) return;

          // push replacement if same page
          print(
              "${currentRouteName} == ${info.routeName}: ${currentRouteName == info.routeName}");
          // push new if some othher page from home
          //
          if (isActive) {
            Navigator.of(context).pop();
            // router.replace(info);
            router.popAndPush(info);
          }

          // if (router.current.name == HomeRoute.name) {
          //   router.push(info);
          // } else {
          //   router.replace(info);
          // }
        },
      ),
    );
  }
}

final _expandedProvider = StateProvider<bool>((_) => false);

class _DrawerMenu extends HookWidget {
  const _DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allPis = useProvider(allPisProvider);
    final expanded = useProvider(_expandedProvider);

    final double o = 80;
    return AnimatedContainer(
      duration: kThemeChangeDuration,
      curve: Curves.ease,
      height: expanded.state ? allPis.length * o : 0,
      child: AnimatedOpacity(
        duration: kThemeChangeDuration,
        curve: Curves.ease,
        opacity: expanded.state ? 1 : 0,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: allPis
              .map((e) => Container(
                    color: e.primaryColor,
                    height: o,
                    child: ListTile(
                      title: Text(e.title),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _DrawerHeader extends HookWidget {
  const _DrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activePi = useProvider(activePiProvider);
    final allPis = useProvider(allPisProvider);
    final expanded = useProvider(_expandedProvider);

    return UserAccountsDrawerHeader(
      accountName: Row(
        children: [
          ActivePiTitle(),
          // PiStatusIndicator(enabled: false),
        ],
      ),
      onDetailsPressed: () {
        expanded.state = !expanded.state;
      },
      accountEmail: null,
      currentAccountPicture: _PiAvatar(
        pi: activePi,
        onTap: () {},
      ),
      otherAccountsPictures: allPis
          .where((element) => element != activePi)
          .map((currentPi) => _PiAvatar(
                pi: currentPi,
                onTap: () {
                  print('TODO');
                  // context.read(activePiProvider).state = currentPi;
                },
              ))
          .toList(),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
            BetterSettingsRoute(),
          ),
        ],
      ),
    );
  }
}
