import 'package:flutter/material.dart';

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
      color: color,
      child: Column(
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
      ),
    );
  }
}
