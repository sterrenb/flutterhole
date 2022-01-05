import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/views/privacy_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/about/app_version.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class AboutView extends HookConsumerWidget {
  const AboutView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsView()));
              },
              icon: const Icon(KIcons.settings)),
        ],
      ),
      body: MobileMaxWidth(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: const Text('FlutterHole for Pi-Hole®'),
              subtitle: Row(
                children: [
                  const Text('Made by '),
                  Text(
                    'TSter',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              // onTap: () {
              //   WebService.launchUrlInBrowser(KUrls.developerHomeUrl);
              // },
              trailing: const SizedBox(
                width: 56,
                child: Center(child: LogoImage()),
              ),
            ),
            // const Divider(),
            const AppVersionListTile(),
            const Divider(),
            const ListTitle('Help'),
            ListTile(
              leading: const Icon(KIcons.privacy),
              title: const Text('Privacy'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PrivacyView(),
                    fullscreenDialog: true));
              },
            ),
            // ListTile(
            //   leading: Opacity(
            //     opacity: context.isLight ? 0.5 : 1.0,
            //     child: const ThemedLogoImage(
            //       width: 24.0,
            //       height: 24.0,
            //     ),
            //   ),
            //   title: const Text('View the introduction'),
            //   trailing: const Icon(KIcons.push),
            //   onTap: () {
            //     // context.router.push(OnboardingRoute(isInitialPage: false));
            //   },
            // ),
            ListTile(
              leading: const Icon(KIcons.bugReport),
              title: const Text('Submit a bug report'),
              trailing: const Icon(KIcons.openUrl),
              onTap: () {
                WebService.launchUrlInBrowser(KUrls.githubIssuesUrl);
              },
            ),
            ListTile(
              leading: const Icon(KIcons.community),
              title: Row(
                children: [
                  const Text('Support from '),
                  Text(
                    '/r/pihole/',
                    style: GoogleFonts.firaMono(),
                  ),
                  // const Text(' on Reddit'),
                ],
              ),
              trailing: const Icon(KIcons.openUrl),
              onTap: () {
                WebService.launchUrlInBrowser(KUrls.piholeCommunity);
              },
            ),
            const Divider(),
            const ListTitle('Support the developer'),
            ListTile(
              leading: const Icon(KIcons.review),
              title: const Text('Write a review'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                if (!kIsWeb) {
                  InAppReview.instance.openStoreListing();
                } else {
                  WebService.launchUrlInBrowser(KUrls.playStoreUrl);
                }
              },
            ),

            ListTile(
              leading: const Icon(KIcons.donate),
              title: const Text('Donate'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                showModal(
                    context: context,
                    builder: (context) {
                      return ModalAlertDialog(
                        title: 'Donate',
                        canCancel: false,
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            Text(
                                'Your donation supports the development of this free app.'),
                            SizedBox(height: 8.0),
                            Text('Thank you in advance!'),
                            SizedBox(height: 24.0),
                            AppWrap(alignment: WrapAlignment.center, children: [
                              UrlOutlinedButton(
                                url: KUrls.payPalUrl,
                                text: 'Paypal',
                              ),
                              UrlOutlinedButton(
                                url: KUrls.githubHomeUrl,
                                text: 'GitHub',
                              ),
                              UrlOutlinedButton(
                                url: KUrls.koFiUrl,
                                text: 'Ko-fi',
                              ),
                            ]),
                            SizedBox(height: 24.0),
                          ],
                        ),
                      );
                    });
              },
            ),
            ListTile(
              leading: Opacity(
                opacity: context.isLight ? 0.5 : 1.0,
                child: const GithubImage(width: 24.0),
              ),
              title: const Text('Star on GitHub'),
              trailing: const Icon(KIcons.openUrl),
              onTap: () => WebService.launchUrlInBrowser(KUrls.githubHomeUrl),
            ),
            const Divider(),
            const ListTitle('Other'),
            ListTile(
              leading: const Icon(KIcons.share),
              title: const Text('Share the app'),
              trailing: const Icon(KIcons.push),
              onTap: () {
                Share.share(KUrls.githubHomeUrl,
                    subject: 'FlutterHole for Pi-Hole®');
              },
            ),
            ListTile(
              leading: const Icon(KIcons.playStore),
              title: const Text('Visit the Google Play page'),
              trailing: const Icon(KIcons.openUrl),
              onTap: () {
                WebService.launchUrlInBrowser(KUrls.playStoreUrl);
              },
            ),
            ListTile(
              leading: const Icon(KIcons.pihole),
              title: const Text('Visit the Pi-hole website'),
              trailing: const Icon(KIcons.openUrl),
              onTap: () {
                WebService.launchUrlInBrowser(KUrls.piHomeUrl);
              },
            ),
            const ListTile(),
          ],
        ),
      ),
    );
  }
}