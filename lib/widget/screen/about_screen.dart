import 'package:flutter/material.dart';
import 'package:flutterhole/service/browser.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
        title: 'About',
        body: ListView(
          children: <Widget>[
            FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (BuildContext context,
                    AsyncSnapshot<PackageInfo> snapshot) {
                  if (snapshot.hasData) {
                    PackageInfo info = snapshot.data;
                    return ListTile(
                      title: Text(info.packageName),
                      subtitle:
                          Text('v' + info.version + '+' + info.buildNumber),
                    );
                  }

                  return ListTile(
                    title: Text('FlutterHole'),
                    subtitle: Text('unknown version'),
                  );
                }),
            Divider(),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('View the source on GitHub'),
              onTap: () =>
                  launchURL('https://github.com/sterrenburg/flutterhole/'),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Make a wish'),
              onTap: () =>
                  launchURL('https://beerpay.io/sterrenburg/flutterhole'),
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Rate the app'),
              onTap: () => LaunchReview.launch(),
            ),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text('Submit an issue on GitHub'),
              onTap: () => launchURL(
                  'https://github.com/sterrenburg/flutterhole/issues/new'),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy'),
              onTap: () =>
                  Globals.navigateTo(
                    context,
                    privacyPath,
                  ),
            ),
            ListTile(
              leading: Icon(Icons.spa),
              title: Text('Visit the Pi-hole website'),
              onTap: () => launchURL('https://pi-hole.net/'),
            ),
          ],
        ));
  }
}
