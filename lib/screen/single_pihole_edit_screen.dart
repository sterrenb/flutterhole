import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/widget/status/single_pihole_view.dart';

class SinglePiholeEditScreen extends StatelessWidget {
  final Pihole pihole;

  const SinglePiholeEditScreen({Key key, @required this.pihole})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text('Editing ${pihole.title}'),
            ],
          ),
        ),
        body: SinglePiholeView(
          provided: pihole,
        ));
  }
}
