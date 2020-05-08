import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:flutterhole/features/routing/presentation/pages/privacy_page.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/widgets/layout/animated_opener.dart';
import 'package:flutterhole/widgets/layout/list_title.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';

const String kAppUrl =
    'https://play.google.com/store/apps/details?id=sterrenburg.github.flutterhole';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        PackageInfo packageInfo;
        if (snapshot.hasData) {
          packageInfo = snapshot.data;
        }

        return Scaffold(
          drawer: DefaultDrawer(),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Text('About'),
//                expandedHeight: kSliverAppBarHeight,
                flexibleSpace: FlexibleSpaceBar(
//                  background: SvgPicture.asset(
//                    'assets/shared_workspace.svg',
//                    fit: BoxFit.cover,
//                  ),
                    ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Row(
                        children: <Widget>[
                          Text(
                            '${packageInfo?.appName}',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
//                          Padding(
//                            padding:
//                                const EdgeInsets.symmetric(horizontal: 8.0),
//                            child: ShareQrButton(
//                              tooltip: 'Share this app with QR',
//                              data: kAppUrl,
//                            ),
//                          )
                        ],
                      ),
                      subtitle: Text(
                        'Made by Sterrenburg',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        KIcons.version,
                        color: KColors.success,
                      ),
                      trailing: FlatButton(
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationName: '${packageInfo?.appName}',
                            applicationVersion: '${packageInfo?.version}',
                            applicationLegalese: 'Made by Sterrenburg',
                            children: <Widget>[
                              SizedBox(height: 24),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyText2,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            'FlutterHole is a free third party Android application '
                                            'for interacting with your Pi-Hole® server. '
                                            '\n\n'
                                            'FlutterHole is open source, which means anyone '
                                            'can view the code that runs your app. '
                                            'You can find the repository on Github.'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        child: Text('Details'),
                      ),
                      title: Text('Version'),
                      subtitle: Text(
                          '${packageInfo?.version} (build #${packageInfo?.buildNumber})'),
                    ),
                  ],
                ),
                Divider(),
                _AboutTiles(packageInfo: packageInfo),
              ])),
            ],
          ),
        );
      },
    );
  }
}

class _AboutTiles extends StatelessWidget {
  const _AboutTiles({
    Key key,
    @required this.packageInfo,
  }) : super(key: key);

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTitle('Help'),
        AnimatedOpener(
          closed: (context) => _AboutTile(
            KIcons.privacy,
            text: 'Privacy',
          ),
          opened: (context) => PrivacyPage(
            privacyReadmeTextFuture:
                getIt<BrowserService>().fetchPrivacyReadmeText(),
          ),
        ),
        _AboutTile(
          KIcons.bugReport,
          text: 'Submit a bug report',
          onTap: () => getIt<BrowserService>().launchUrl(
              'https://github.com/sterrenburg/flutterhole/issues/new'),
        ),
        Divider(),
        ListTitle('Support the developer'),
        _AboutTile(
          KIcons.rate,
          text: 'Rate the app',
          onTap: () => getIt<BrowserService>().launchReview(),
        ),
        _AboutTile(
          KIcons.github,
          text: 'Star on GitHub',
          onTap: () => getIt<BrowserService>()
              .launchUrl('https://github.com/sterrenburg/flutterhole/'),
        ),
        Divider(),
        ListTitle('Other'),
        _AboutTile(
          KIcons.share,
          text: 'Share this app',
          onTap: () => Share.share(kAppUrl,
              subject: 'Check out ${packageInfo?.appName}'),
        ),
        _AboutTile(
          KIcons.pihole,
          text: 'Visit the Pi-hole website',
          onTap: () =>
              getIt<BrowserService>().launchUrl('https://pi-hole.net/'),
        ),
      ],
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile(
    this.iconData, {
    @required this.text,
    this.onTap,
    Key key,
  }) : super(key: key);

  final IconData iconData;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData),
      trailing: Icon(KIcons.open),
      title: Text(text),
      onTap: onTap,
    );
  }
}
