import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class PiholeSettingsFormCard extends StatelessWidget {
  const PiholeSettingsFormCard({
    Key key,
    @required this.formKey,
    @required this.children,
  }) : super(key: key);

  final GlobalKey<FormBuilderState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }
}
