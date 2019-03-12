import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/cancel_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/scan_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/snack_bar.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/edit_form.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_token.dart';

class PreferenceViewString extends StatefulWidget {
  final Preference preference;

  const PreferenceViewString({Key key, @required this.preference})
      : super(key: key);

  @override
  PreferenceViewStringState createState() {
    return new PreferenceViewStringState();
  }
}

class PreferenceViewStringState extends State<PreferenceViewString> {
  /// Shows an [AlertDialog] with [content].
  Future _showDialog(BuildContext context, Widget content) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.preference.title),
            content: content,
          );
        });
  }

  /// Shows an [AlertDialog] with an editable preference field
  Future _openPreferenceDialog(AsyncSnapshot<dynamic> snapshot,
      BuildContext context, TextEditingController controller) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return _alertPreferenceDialog(
              EditForm(
                  formKey: formKey,
                  controller: controller,
                  type: widget.preference.defaultValue.runtimeType),
              context);
        });
  }

  AlertDialog _alertPreferenceDialog(EditForm editForm, BuildContext context) {
    List<Widget> actions = [
      CancelButton(),
      FlatButton(
        child: Text('OK'),
        onPressed: () {
          if (editForm.formKey.currentState.validate()) {
            widget.preference
                .set(value: editForm.controller.value.text)
                .catchError((e) {
              showSnackBar(context, e.toString());
            }).then((bool didSet) {
              if (widget.preference.onSet != null) {
                setState(() {});
                widget.preference.onSet(
                    context: context,
                    didSet: didSet,
                    value: editForm.controller.value.text);
              }
            });
            Navigator.pop(context);
          }
        },
      )
    ];

    if (widget.preference.runtimeType == PreferenceToken) {
      actions.insert(0, ScanButton(controller: editForm.controller));
    }

    return AlertDialog(
      title: Text(widget.preference.title),
      content: editForm,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: widget.preference.get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final controller =
            TextEditingController(text: snapshot.data.toString());
            return ListTile(
              leading: Icon(widget.preference.iconData),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(widget.preference.title),
                  IconButton(
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.grey,
                      size: 16.0,
                    ),
                    onPressed: () =>
                        _showDialog(context, widget.preference.help),
                  )
                ],
              ),
              subtitle: Text(controller.text),
              onTap: () {
                return _openPreferenceDialog(snapshot, context, controller);
              },
              onLongPress: () {
                showSnackBar(context, widget.preference.description,
                    duration: Duration(milliseconds: 1500));
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}

class PreferenceViewBool extends StatefulWidget {
  final PreferenceBool preference;

  const PreferenceViewBool({Key key, this.preference}) : super(key: key);

  @override
  _PreferenceViewBoolState createState() => _PreferenceViewBoolState();
}

class _PreferenceViewBoolState extends State<PreferenceViewBool> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: widget.preference.get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return SwitchListTile(
              title: Text(widget.preference.title),
              value: snapshot.data,
              secondary: Icon(widget.preference.iconData),
              onChanged: (bool value) {
                widget.preference.set(value: value).then((bool didSet) {
                  if (widget.preference.onSet != null) {
                    // Trigger rebuild with the newly edited controller.text
                    setState(() {});
                    widget.preference
                        .onSet(context: context, didSet: didSet, value: value);
                  }
                });
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}
