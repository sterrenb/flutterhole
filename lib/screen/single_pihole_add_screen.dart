import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/widget/status/single_pihole_view.dart';

class SinglePiholeAddScreen extends StatelessWidget {
  final Pihole provided = Pihole(title: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text('Add a new Pihole'),
            ],
          ),
        ),
        body: SinglePiholeView(
          provided: provided,
        ));
  }
}
