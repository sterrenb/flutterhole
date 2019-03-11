import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/cancel_button.dart';

/// A form that allows users to edit a value, with validation depending on its [type].
class EditForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Type type;

  const EditForm({Key key,
    @required this.formKey,
    @required this.controller,
    this.type = String})
      : super(key: key);

  @override
  _EditFormState createState() {
    return new _EditFormState(formKey, controller);
  }
}

class _EditFormState extends State<EditForm> {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  _EditFormState(this.formKey, this.controller);

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

/// Shows an [AlertDialog] with an editable text field
Future openEditDialog(BuildContext context, TextEditingController controller) {
  final formKey = GlobalKey<FormState>();
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertConfigDialog(
            EditForm(formKey: formKey, controller: controller, type: String),
            context);
      });
}

AlertDialog alertConfigDialog(EditForm editForm, BuildContext context) {
  List<Widget> actions = [
    CancelButton(),
    FlatButton(
      child: Text('OK'),
      onPressed: () {
        if (editForm.formKey.currentState.validate()) {
          final PiConfig piConfig = AppState
              .of(context)
              .piConfig;
          piConfig
              .addNew(editForm.controller.value.text)
              .then((int newConfigIndex) {
            piConfig.switchConfig(context: context, index: newConfigIndex);
//                .then((bool didSwitch) {
//              setState(() {});
//            });
          });
          Navigator.pop(context);
        }
      },
    )
  ];

  return AlertDialog(
    title: Text('Enter a name'),
    content: editForm,
    actions: actions,
  );
}
