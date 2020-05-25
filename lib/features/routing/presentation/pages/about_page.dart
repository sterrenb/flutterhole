import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:flutterhole/features/routing/presentation/pages/page_scaffold.dart';
import 'package:flutterhole/features/routing/presentation/pages/privacy_page.dart';
import 'package:flutterhole/features/settings/services/package_info_service.dart';
import 'package:flutterhole/widgets/layout/animations/animated_opener.dart';
import 'package:flutterhole/widgets/layout/lists/list_title.dart';
import 'package:flutterhole/widgets/layout/lists/open_url_tile.dart';
import 'package:flutterhole/widgets/layout/notifications/dialogs.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';

const Color _jpegBackgroundColor = Colors.white;
final Color _iconColor = Colors.green.shade900;

const int _subTileCount = 2;

class _Spacer extends StatelessWidget {
  const _Spacer({
    @required this.width,
    @required this.color,
    Key key,
  }) : super(key: key);

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
      ),
    );
  }
}

class LogoInspector extends StatefulWidget {
  const LogoInspector({
    Key key,
    @required this.screenWidth,
  }) : super(key: key);

  final double screenWidth;

  @override
  _LogoInspectorState createState() => _LogoInspectorState();
}

class _LogoInspectorState extends State<LogoInspector> {
  Color _color;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _color = _iconColor;

    _scrollController = ScrollController(
      initialScrollOffset: widget.screenWidth * 3,
    );

    _scrollController.addListener(() {
      final offset = _scrollController.offset;

      final pageOffset = (offset / widget.screenWidth) - 3;

      if (pageOffset <= -1.5) {
        setState(() {
          _color = ThemeData.dark().cardColor;
        });
      } else if (pageOffset >= -0.2 && pageOffset <= 0.2) {
        setState(() {
          _color = _iconColor;
        });
      } else if (pageOffset >= 3) {
        setState(() {
          _color = Colors.purple;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildSpacers(double screenWidth) {
    return <Widget>[
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.2),
      ),
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.4),
      ),
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.6),
      ),
      _Spacer(
        width: screenWidth / _subTileCount,
        color: _jpegBackgroundColor.withOpacity(.8),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      decoration: BoxDecoration(
        // TODO perhaps not white if we make this image a png
        color: _color,
      ),
      curve: Curves.easeInOut,
      width: widget.screenWidth * 4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            width: widget.screenWidth,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Image(
                    image: AssetImage('assets/icon/old_icon.png'),
                    width: widget.screenWidth / 2,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    leading: Icon(KIcons.info),
                    title: Text('Original logo design'),
                  ),
                ),
              ],
            ),
          ),
          ..._buildSpacers(widget.screenWidth / 2),
          ..._buildSpacers(widget.screenWidth / 2).reversed.toList(),
          Container(
            width: widget.screenWidth,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Image(
                    image: AssetImage('assets/icon/logo.png'),
                    width: widget.screenWidth / 2,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: OpenUrlTile(
                    url: KStrings.logoDesignerUrl,
                    leading: Icon(KIcons.info),
                    title: Text('Logo design by Mathijs Sterrenburg'),
                  ),
                ),
              ],
            ),
          ),
          ..._buildSpacers(widget.screenWidth),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Image(
              image: AssetImage('assets/images/logos.jpeg'),
              width: widget.screenWidth * 2,
            ),
          ),
          ..._buildSpacers(widget.screenWidth / 2).reversed.toList(),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final packageInfo = getIt<PackageInfoService>().packageInfo;

    return PageScaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('About'),
            flexibleSpace: FlexibleSpaceBar(),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text('${packageInfo?.appName}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline4),
                  subtitle: Text(
                    'Made by Sterrenburg',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  trailing: SizedBox(
                    width: 56,
                    child: Ink.image(
                      image: AssetImage('assets/icon/icon.png'),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (sheetContext) {
                                final screenWidth =
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width;

                                return LogoInspector(screenWidth: screenWidth);
                              });
                        },
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    KIcons.version,
                    color: KColors.success,
                  ),
                  trailing: FlatButton(
                    onPressed: () {
                      showAppDetailsDialog(context, packageInfo);
                    },
                    child: Text('Details'),
                  ),
                  title: Text('Version'),
                  subtitle: Text('${packageInfo.versionAndBuildString}'),
                ),
              ],
            ),
            Divider(),
            _AboutTiles(packageInfo: packageInfo),
          ])),
        ],
      ),
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
          onTap: () =>
              getIt<BrowserService>().launchUrl(KStrings.githubIssuesUrl),
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
          onTap: () =>
              getIt<BrowserService>().launchUrl(KStrings.githubHomeUrl),
        ),
        Divider(),
        ListTitle('Other'),
        _AboutTile(
          KIcons.share,
          text: 'Share this app',
          onTap: () => Share.share(KStrings.playStoreUrl,
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
