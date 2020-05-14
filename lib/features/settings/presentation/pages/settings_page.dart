import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PiholeThemeBuilder(
      child: Scaffold(
        drawer: DefaultDrawer(),
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListView(
          children: <Widget>[
//            UserPreferencesListTile(),
            ListTile(
              title: Text('My Piholes'),
              leading: Icon(KIcons.pihole),
              trailing: Icon(KIcons.open),
              onTap: () {
                getIt<RouterService>().push(RouterService.allPiholes);
              },
            ),
            ListTile(
              title: Text('Preferences'),
              leading: Icon(KIcons.preferences),
              trailing: Icon(KIcons.open),
              onTap: () {
                getIt<RouterService>().push(RouterService.userPreferences);
              },
            ),

          ],
        ),
      ),
    );
  }
}
