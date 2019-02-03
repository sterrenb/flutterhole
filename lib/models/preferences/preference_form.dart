import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

/// A form that allows users to edit a [Preference].
class PreferenceForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  const PreferenceForm(
      {Key key, @required this.formKey, @required this.controller})
      : super(key: key);

  @override
  _PreferenceFormState createState() {
    return new _PreferenceFormState(formKey, controller);
  }
}

class _PreferenceFormState extends State<PreferenceForm> {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  _PreferenceFormState(this.formKey, this.controller);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: 'Hint text here'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }
        },
      ),
    );
  }
}
