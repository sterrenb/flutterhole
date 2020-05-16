import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class BasicAuthenticationUsernameFormTile extends StatelessWidget {
  const BasicAuthenticationUsernameFormTile({
    Key key,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderTextField(
        attribute: 'basicAuthenticationUsername',
        decoration: decoration.copyWith(
          labelText: 'BasicAuth Username',
        ),
        autocorrect: false,
        maxLines: 1,
      ),
    );
  }
}
