import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/about/app_version.dart';
import 'package:flutterhole_web/features/about/logo.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/layout/context_extensions.dart';
import 'package:flutterhole_web/features/layout/list.dart';
import 'package:flutterhole_web/features/layout/media_queries.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
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
          actions: [
            ThemeModeToggle(),
          ],
        ),
        body: ListView(
          padding: context.clampedBodyPadding,
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(height: 10),
            ListTile(
              title: Text(
                'FlutterHole for Pi-Hole®',
              ),
              subtitle: Text('Made by Thomas Sterrenburg'),
              trailing: Container(
                // roughly center the logo with the `licences button`
                width: 80.0,
                child: Center(child: LogoIcon()),
              ),
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
              leading: Opacity(
                opacity: context.isLight ? 0.5 : 1.0,
                child: ThemedLogoImage(
                  width: 24.0,
                  height: 24.0,
                ),
              ),
              title: Text('View the introduction'),
              trailing: Icon(KIcons.push),
              onTap: () {
                context.router.push(OnboardingRoute(isInitialPage: false));
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
            _DonateTile(),
            Divider(),
            ListTitle('Other'),
            ListTile(
              leading: Icon(KIcons.share),
              title: Text('Share this app'),
              trailing: Icon(KIcons.push),
              onTap: () {
                Share.share('${KUrls.playStoreUrl}',
                    subject: 'FlutterHole for Pi-Hole®');
              },
            ),
            ListTile(
              leading: Icon(KIcons.playStore),
              title: Text('Visit the Google Play page'),
              trailing: Icon(KIcons.push),
              onTap: () {
                launchUrl(KUrls.playStoreUrl);
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

class _DonateTile extends StatelessWidget {
  const _DonateTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(KIcons.donate),
      title: Text('Donate'),
      onTap: () {
        showModal(
            context: context,
            builder: (context) {
              return ConfirmationDialog(
                title: 'Donate',
                onConfirm: () {},
                canCancel: false,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        'Your donation supports the development of this free app.'),
                    const SizedBox(height: 8.0),
                    Text('Thank you in advance! 💰'),
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
                      title: Text('GitHub'),
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
    );
  }
}

class _StarOnGitHubTile extends HookWidget {
  const _StarOnGitHubTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Opacity(
        opacity: context.isLight ? 0.5 : 1.0,
        child: GithubImage(width: 24.0),
      ),
      title: Text('Star on GitHub'),
      trailing: Icon(KIcons.push),
      onTap: () => launchUrl(KUrls.githubHomeUrl),
    );
  }
}

class GithubImage extends StatelessWidget {
  const GithubImage({Key? key, this.width}) : super(key: key);

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image(
        width: width,
        image: AssetImage(
          context.isLight
              ? 'assets/icons/github_dark.png'
              : 'assets/icons/github_light.png',
        ));
  }
}
