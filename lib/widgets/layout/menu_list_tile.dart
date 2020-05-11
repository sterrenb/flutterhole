import 'package:flutter/material.dart';

class MenuListTile extends StatelessWidget {
  final String title;
  final double leftPadding;


  MenuListTile(this.title, {this.leftPadding = 10.0, });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 0.0, top: 20.0),
      child: Text(
        title,
        style:
            TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold),
      ),
    );
  }
}
