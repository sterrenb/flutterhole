import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:sterrenburg.github.flutterhole/models/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/default_scaffold.dart';
import 'package:sterrenburg.github.flutterhole/screens/privacy_screen.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<Widget> _aboutTiles(info) =>
      [
        ListTile(
          title: Text('FlutterHole'),
          subtitle: Text('v' + info.version + '+' + info.buildNumber),
        ),
        ListTile(
          leading: Icon(Icons.code),
          title: Text('View the source on GitHub'),
          onTap: () =>
              ApiProvider.launchURL(
                  'https://github.com/sterrenburg/flutterhole/'),
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text('Rate the app'),
          onTap: () =>
              LaunchReview.launch(
                  androidAppId: 'sterrenburg.github.flutterhole'),
        ),
        ListTile(
          leading: Icon(Icons.bug_report),
          title: Text('Submit an issue on GitHub'),
          onTap: () =>
              ApiProvider.launchURL(
                  'https://github.com/sterrenburg/flutterhole/issues/new'),
        ),
        ListTile(
          leading: Icon(Icons.lock),
          title: Text('Privacy'),
          onTap: () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrivacyScreen())),
        ),
        ListTile(
          leading: Icon(Icons.spa),
          title: Text('Visit the Pi-hole website'),
          onTap: () =>
              ApiProvider.launchURL(
                  'https://pi-hole.net/'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
        title: 'About',
        body: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder:
                (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
              if (snapshot.hasData) {
                PackageInfo info = snapshot.data;
                return Column(
                  children: ListTile.divideTiles(
                      context: context, tiles: _aboutTiles(info))
                      .toList(),
                );
              }

              return CircularProgressIndicator();
            }));
  }
}
