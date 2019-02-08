import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

/// A form that allows users to edit a [Preference].
class PreferenceForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Type type;

  const PreferenceForm({Key key,
    @required this.formKey,
    @required this.controller,
    this.type = String})
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

  TextFormField textFormFieldString() {
    return TextFormField(
      controller: controller,
      autofocus: true,
      validator: (value) {
        if (value.isEmpty) {
          return ('Please enter some text');
        }
      },
    );
  }

  TextFormField textFormFieldInt() {
    return TextFormField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(hintText: 'Hint text here'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a number';
        }
        final n = num.tryParse(value);
        if (n == null) {
          return '"$value" is not a valid number';
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextFormField textFormField;
    switch (widget.type) {
      case int:
        textFormField = textFormFieldInt();
        break;
      default:
        textFormField = textFormFieldString();
    }
    return Form(
      key: formKey,
      child: textFormField,
    );
  }
}
