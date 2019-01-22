import 'package:flutter/material.dart';

class PreferenceForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  const PreferenceForm(
      {Key key, @required this.formKey, @required this.controller})
      : super(key: key);

  @override
  PreferenceFormState createState() {
    return new PreferenceFormState(formKey, controller);
  }
}

class PreferenceFormState extends State<PreferenceForm> {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  PreferenceFormState(this.formKey, this.controller);

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
