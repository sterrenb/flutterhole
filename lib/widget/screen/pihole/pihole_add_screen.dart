import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/widget/scaffold.dart';
import 'package:flutterhole_again/widget/status/single_pihole_view.dart';

class PiholeAddScreen extends StatelessWidget {
  final Pihole provided = Pihole(title: '');

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
        titleString: 'Add a new Pihole',
        body: SinglePiholeView(
          provided: provided,
        ));
  }
}
