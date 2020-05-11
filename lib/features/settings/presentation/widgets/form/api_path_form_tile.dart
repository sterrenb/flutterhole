import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class ApiPathFormTile extends StatelessWidget {
  const ApiPathFormTile({
    Key key,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final InputDecoration decoration;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderTextField(
        attribute: 'apiPath',
        decoration: decoration.copyWith(
            labelText: 'API path',
            helperText:
                'For normal use cases, the API path is "${const PiholeSettings().apiPath}".'),
        autocorrect: false,
        maxLines: 1,
      ),
    );
  }
}
