import 'package:flutter/material.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:flutterhole_again/widget/pihole/single_pihole_view.dart';
import 'package:flutterhole_again/widget/scaffold.dart';

class PiholeAddScreen extends StatelessWidget {
  final Pihole original = Pihole(title: '');

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
        titleString: 'Add a new Pihole',
        body: SinglePiholeView(
          original: original,
        ));
  }
}
