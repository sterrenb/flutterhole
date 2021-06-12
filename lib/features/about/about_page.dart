import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/about/app_version.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/query_log/logo_inspector.dart';
import 'package:in_app_review/in_app_review.dart';

class ListTitle extends StatelessWidget {
  const ListTitle(
    this.message, {
    Key? key,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: Theme.of(context).accentColor),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10),
          ListTile(
            title: Text(
              'FlutterHole for Pi-Hole®',
            ),
            subtitle: Text('Made by Thomas Sterrenburg'),
            leading: SizedBox(
              width: 56.0,
              child: Ink.image(
                image: AssetImage('assets/icons/icon.png'),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (sheetContext) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          return LogoInspector(screenWidth: screenWidth);
                          // return LogoInspector(screenWidth: screenWidth);
                        });
                  },
                ),
              ),
            ),
          ),
          Divider(),
          AppVersionListTile(),
          Divider(),
          ListTitle('Support the developer'),
          ListTile(
            leading: Icon(KIcons.review),
            title: Text('Write a review'),
            onTap: () {
              final InAppReview inAppReview = InAppReview.instance;
              inAppReview.openStoreListing();
            },
          ),
          ListTile(
            leading: Image(
                width: 24.0,
                image: AssetImage('assets/icons/github_light.png')),
            title: Text('Star on GitHub'),
            onTap: () => launchUrl(KUrls.githubHomeUrl),
          ),
        ],
      ),
    );
  }
}
