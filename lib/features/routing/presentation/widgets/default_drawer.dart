import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/blocs/extras_bloc.dart';
import 'package:flutterhole/features/routing/presentation/notifiers/drawer_notifier.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer_header.dart';
import 'package:flutterhole/features/routing/presentation/widgets/drawer_menu.dart';
import 'package:flutterhole/features/routing/presentation/widgets/drawer_tile.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/services/package_info_service.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/widgets/layout/notifications/dialogs.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class DefaultDrawer extends StatelessWidget {
  const DefaultDrawer();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DrawerNotifier>(
      create: (BuildContext context) => DrawerNotifier(),
      child: Drawer(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DefaultDrawerHeader(),
                DrawerMenu(),
                DrawerTile(
                  routeName: RouterService.home,
                  title: Text('Dashboard'),
                  icon: Icon(KIcons.dashboard),
                ),
                DrawerTile(
                  routeName: RouterService.queryLog,
                  title: Text('Query log'),
                  icon: Icon(KIcons.queryLog),
                ),
                DrawerTile(
                  routeName: RouterService.whitelist,
                  title: Text('Whitelist'),
                  icon: Icon(KIcons.whitelist),
                ),
                DrawerTile(
                  routeName: RouterService.blacklist,
                  title: Text('Blacklist'),
                  icon: Icon(KIcons.blacklist),
                ),
                DrawerTile(
                  routeName: RouterService.settings,
                  title: Text('Settings'),
                  icon: Icon(KIcons.settings),
                ),
                Divider(),
                DrawerTile(
                  routeName: RouterService.about,
                  title: Text('About'),
                  icon: Icon(KIcons.about),
                ),
                ListTile(
                  title: Text('API Log'),
                  leading: Icon(KIcons.apiLog),
                  onTap: () {
                    getIt<Alice>().showInspector();
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _Footer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String footerMessage = getIt<PreferenceService>().footerMessage;
    final PackageInfo packageInfo = getIt<PackageInfoService>().packageInfo;
    final String temperatureType = getIt<PreferenceService>().temperatureType;

    final textStyle = Theme.of(context).textTheme.caption;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<ExtrasBloc, ExtrasState>(
          buildWhen: (previous, next) {
            if (previous is ExtrasStateSuccess) return false;

            return true;
          },
          builder: (BuildContext context, ExtrasState state) {
            return state.when<Widget>(
              initial: () => Container(),
              loading: () => Container(),
              success: (extras) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          tooltip: 'Temperature',
                          icon: Icon(KIcons.temperature),
                          onPressed: null,
                        ),
                        Text(
                          '${extras.temperature?.toStringAsFixed(2)} ${temperatureType == 'fahrenheit' ? '°F' : '°C'}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          tooltip: 'Load',
                          icon: Icon(KIcons.cpuLoad),
                          onPressed: null,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Center(
                            child: Text(
                              '${extras.load?.map<String>((load) => '${load.toStringAsPrecision(2)}').join(' ')}',
                              style: Theme.of(context).textTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          tooltip: 'Memory usage',
                          icon: Icon(KIcons.memoryUsage),
                          onPressed: null,
                        ),
                        Text(
                          '${extras.memoryUsage?.toStringAsFixed(2)}%',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              failure: (failure) => Container(),
            );
          },
        ),
        ListTile(
          title: Text(
            '${packageInfo.appName} ${packageInfo.versionAndBuildString}',
            style: textStyle,
          ),
          leading: Image(
            image: AssetImage('assets/icon/logo.png'),
            width: 50,
            height: 50,
            color: textStyle.color,
          ),
          subtitle: footerMessage.isEmpty
              ? null
              : Text(
                  '$footerMessage',
                  style: textStyle,
                ),
          onLongPress: () {
            showAppDetailsDialog(context, packageInfo);
          },
        ),
      ],
    );
  }
}
