import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/about/app_version.dart';
import 'package:flutterhole_web/features/about/logo.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/layout/list.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/themes.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActivePiTheme(
      child: Scaffold(
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
            Divider(),
            ListTitle('Help'),
            ListTile(
              leading: Icon(KIcons.privacy),
              title: Text('Privacy'),
              trailing: Icon(KIcons.push),
              onTap: () {
                context.router.push(PrivacyRoute());
              },
            ),
            ListTile(
              leading: Icon(KIcons.bugReport),
              title: Text('Submit a bug report'),
              trailing: Icon(KIcons.push),
              onTap: () {
                launchUrl(KUrls.githubIssuesUrl);
              },
            ),
            Divider(),
            ListTitle('Support the developer'),
            ListTile(
              leading: Icon(KIcons.review),
              title: Text('Write a review'),
              trailing: Icon(KIcons.push),
              onTap: () {
                final InAppReview inAppReview = InAppReview.instance;
                inAppReview.openStoreListing();
              },
            ),
            _StarOnGitHubTile(),
            ListTile(
              leading: Icon(KIcons.donate),
              title: Text('Donate'),
              onTap: () {
                showModal(
                    context: context,
                    builder: (context) {
                      return ConfirmationDialog(
                        title: 'Donate',
                        onConfirm: () {},
                        body: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'You can donate to the developer to support the development of this app.'),
                            const SizedBox(height: 8.0),
                            // Text(
                            //     'The current goal is getting some macOS hardware and an Apple Developer licence to work on an iOS app.'),
                            // const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Text('Thank you in advance! 💰'),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            ListTile(
                              title: Text('Paypal'),
                              trailing: Icon(KIcons.push),
                              onTap: () {
                                launchUrl(KUrls.payPalUrl);
                              },
                            ),
                            ListTile(
                              title: Text('Ko-fi'),
                              trailing: Icon(KIcons.push),
                              onTap: () {
                                launchUrl(KUrls.koFiUrl);
                              },
                            ),
                            ListTile(
                              title: Text('GitHub sponsor'),
                              trailing: Icon(KIcons.push),
                              onTap: () {
                                launchUrl(KUrls.githubSponsor);
                              },
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
            Divider(),
            ListTitle('Other'),
            ListTile(
              leading: Icon(KIcons.share),
              title: Text('Share this app'),
              trailing: Icon(KIcons.push),
              onTap: () {
                Share.share(
                    'Check out FlutterHole for Pi-Hole®: ${KUrls.playStoreUrl}');
              },
            ),
            ListTile(
              leading: Icon(KIcons.pihole),
              title: Text('Visit the Pi-hole website'),
              trailing: Icon(KIcons.push),
              onTap: () {
                launchUrl(KUrls.piHomeUrl);
              },
            ),
            ListTile(),
          ],
        ),
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
      trailing: Icon(KIcons.push),
      onTap: () => launchUrl(KUrls.githubHomeUrl),
    );
  }
}
