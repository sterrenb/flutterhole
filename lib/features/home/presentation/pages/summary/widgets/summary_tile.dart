import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/animate_on_build.dart';

class SummaryTile extends StatelessWidget {
  const SummaryTile({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.color,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: OpenContainer(
        tappable: false,
        closedColor: color,
        closedBuilder: (context, VoidCallback openContainer) {
          return InkWell(
            onTap: openContainer,
            child: _Tile(title, subtitle),
          );
        },
        openBuilder: (BuildContext context, VoidCallback closeContainer) {
          return Scaffold(
            backgroundColor: color,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(child: AnimateOnBuild(child: _Tile(title, subtitle))),
                Flexible(child: Container()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
    this.title,
    this.subtitle, {
    Key key,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Center(
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
