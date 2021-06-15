import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/about/app_version.dart';
import 'package:flutterhole_web/features/about/logo.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
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
            leading: LogoIcon(),
          ),
          Divider(),
          AppVersionListTile(),
          ListTile(
            leading: Icon(KIcons.privacy),
            title: Text('Privacy'),
            trailing: Icon(KIcons.push),
            onTap: () {
              context.router.push(PrivacyRoute());
            },
          ),
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
          _StarOnGitHubTile(),
          ListTile(
            leading: Icon(KIcons.donate),
            title: Text('Donate'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _StarOnGitHubTile extends HookWidget {
  const _StarOnGitHubTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ListTile(
      leading: Opacity(
        opacity: isLight ? 0.5 : 1.0,
        child: Image(
            width: 24.0,
            image: AssetImage(
              isLight
                  ? 'assets/icons/github_dark.png'
                  : 'assets/icons/github_light.png',
            )),
      ),
      title: Text('Star on GitHub'),
      onTap: () => launchUrl(KUrls.githubHomeUrl),
    );
  }
}
