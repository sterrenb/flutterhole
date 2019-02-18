import 'package:flutter/material.dart';
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:sterrenburg.github.flutterhole/screens/settings_screen.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/info_tile.dart';

class WelcomePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget image;

  const WelcomePage({Key key, this.title, this.subtitle, this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        (this.image == null)
            ? Container()
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: this.image,
              ),
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final pageIndexNotifier = ValueNotifier<int>(0);

  final List<WelcomePage> pages = [
    WelcomePage(
      title: 'FlutterHole for Pi-hole®',
      subtitle:
          'Thank you for using FlutterHole, a third party Android application for the Pi-Hole® dashboard.',
    ),
    WelcomePage(
      title: 'Quick Toggle',
      subtitle:
          'Quickly enable and disable your Pi-hole from your home screen or with a single tap in FlutterHole.',
    ),
    WelcomePage(
      title: 'Multiple Configurations',
      subtitle:
          'Using different Pi-holes at home and work? Manage all your Pi-holes and easily switch between them.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: FractionalOffset.center,
      children: <Widget>[
        Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[
            PageView.builder(
                onPageChanged: (index) => pageIndexNotifier.value = index,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Container(
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.only(top: 300.0),
//                    decoration: BoxDecoration(color: piColors[index]),
                      child: Center(child: pages[index]));
                }),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                PageViewIndicator(
                  pageIndexNotifier: pageIndexNotifier,
                  length: pages.length,
                  normalBuilder: (animationController) => Circle(
                        size: 8.0,
                        color: Colors.grey,
                      ),
                  highlightedBuilder: (animationController) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animationController,
                          curve: Curves.ease,
                        ),
                        child: Circle(
                          size: 12.0,
                          color: piColors.first,
                        ),
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        color: piColors.first,
                        child: Text(
                          'Set up your Pi-hole',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(16.0),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsScreen()));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Image.asset(
          'assets/icon/icon.png',
          semanticLabel: 'FlutterHole Logo',
          width: 100.0,
//          alignment: Alignment(0.0, -200.0),
        ),
      ],
    ));
  }
}
