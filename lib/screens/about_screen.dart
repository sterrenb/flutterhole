import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/default_scaffold.dart';
import 'package:package_info/package_info.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
                  children: <Widget>[
                    ListTile(
                      title: Text('FlutterHole'),
                      subtitle:
                          Text('v' + info.version + '+' + info.buildNumber),
                    ),
                    ListTile(
                      title: Text('Rate the app'),
                      onTap: () => print('yay rating'),
                    )
                  ],
                );
              }

              return CircularProgressIndicator();
            }));
  }
}
