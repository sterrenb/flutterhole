import 'package:flutter/material.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/pihole/pihole_edit_form.dart';

class PiholeAddScreen extends StatelessWidget {
  final Pihole original;

  final PiholeEditForm form;

  PiholeAddScreen({Key key})
      : original = Pihole(title: ''),
        form = PiholeEditForm(original: Pihole(title: '')),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(title: 'Add a new Pihole', body: form);
  }
}

class PiholeEditScreen extends StatelessWidget {
  final Pihole pihole;

  const PiholeEditScreen({Key key, @required this.pihole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleScaffold(
        title: 'Editing ${pihole.title}',
        body: PiholeEditForm(
          original: pihole,
        ));
  }
}
