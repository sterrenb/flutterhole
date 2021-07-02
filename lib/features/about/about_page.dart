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
          title: const Text('About'),
          actions: const [
            ThemeModeToggle(),
          ],
        ),
        body: ListView(
          padding: context.clampedBodyPadding,
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 10),
            const ListTile(
              title: Text(
                'FlutterHole for Pi-Hole®',
              ),
              subtitle: Text('Made by Thomas Sterrenburg'),
              trailing: SizedBox(
                // roughly center the logo with the `licences button`
                width: 80.0,
                child: Center(child: LogoIcon()),
              ),
            ),
            const Divider(),
            const AppVersionListTile(),
            const Divider(),
            const ListTitle('Help'),
            ListTile(
              leading: const Icon(KIcons.privacy),
              title: const Text('Privacy'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                context.router.push(const PrivacyRoute());
              },
            ),
            ListTile(
              leading: Opacity(
                opacity: context.isLight ? 0.5 : 1.0,
                child: const ThemedLogoImage(
                  width: 24.0,
                  height: 24.0,
                ),
              ),
              title: const Text('View the introduction'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                context.router.push(OnboardingRoute(isInitialPage: false));
              },
            ),
            ListTile(
              leading: const Icon(KIcons.bugReport),
              title: const Text('Submit a bug report'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                launchUrl(KUrls.githubIssuesUrl);
              },
            ),
            const Divider(),
            const ListTitle('Support the developer'),
            ListTile(
              leading: const Icon(KIcons.review),
              title: const Text('Write a review'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                final InAppReview inAppReview = InAppReview.instance;
                inAppReview.openStoreListing();
              },
            ),
            const _StarOnGitHubTile(),
            const _DonateTile(),
            const Divider(),
            const ListTitle('Other'),
            ListTile(
              leading: const Icon(KIcons.share),
              title: const Text('Share this app'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                Share.share(KUrls.playStoreUrl,
                    subject: 'FlutterHole for Pi-Hole®');
              },
            ),
            ListTile(
              leading: const Icon(KIcons.playStore),
              title: const Text('Visit the Google Play page'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                launchUrl(KUrls.playStoreUrl);
              },
            ),
            ListTile(
              leading: const Icon(KIcons.pihole),
              title: const Text('Visit the Pi-hole website'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                launchUrl(KUrls.piHomeUrl);
              },
            ),
            const ListTile(),
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
      leading: const Icon(KIcons.donate),
      title: const Text('Donate'),
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
                    const Text(
                        'Your donation supports the development of this free app.'),
                    const SizedBox(height: 8.0),
                    const Text('Thank you in advance! 💰'),
                    const SizedBox(height: 8.0),
                    ListTile(
                      title: const Text('Paypal'),
                      trailing: const Icon(KIcons.push),
                      onTap: () {
                        launchUrl(KUrls.payPalUrl);
                      },
                    ),
                    ListTile(
                      title: const Text('Ko-fi'),
                      trailing: const Icon(KIcons.push),
                      onTap: () {
                        launchUrl(KUrls.koFiUrl);
                      },
                    ),
                    ListTile(
                      title: const Text('GitHub'),
                      trailing: const Icon(KIcons.push),
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
        child: const GithubImage(width: 24.0),
      ),
      title: const Text('Star on GitHub'),
      trailing: const Icon(KIcons.push),
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
