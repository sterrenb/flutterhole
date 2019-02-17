import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/cancel_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/scan_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_form.dart';

class PreferenceView extends StatefulWidget {
  final Preference preference;
  final bool addScanButton;

  const PreferenceView({Key key,
    @required this.preference,
    this.addScanButton = false})
      : super(key: key);

  @override
  PreferenceViewState createState() {
    return new PreferenceViewState();
  }
}

class PreferenceViewState extends State<PreferenceView> {
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
  Future openPrefDialog(AsyncSnapshot<dynamic> snapshot, BuildContext context,
      TextEditingController controller) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertPrefDialog(
              EditForm(
                  formKey: formKey,
                  controller: controller,
                  type: widget.preference.defaultValue.runtimeType),
              context);
        });
  }

  AlertDialog alertPrefDialog(EditForm editForm, BuildContext context) {
    List<Widget> actions = [
      CancelButton(),
      FlatButton(
        child: Text('OK'),
        onPressed: () {
          if (editForm.formKey.currentState.validate()) {
            widget.preference
                .set(value: editForm.controller.value.text)
                .then((bool didSet) {
              if (didSet) {
                if (widget.preference.onSet != null) {
                  setState(() {});
                  widget.preference.onSet(
                      context: context,
                      didSet: didSet,
                      value: editForm.controller.value.text);
                }
              } else {
                Fluttertoast.showToast(
                    msg: 'Failed to set ${widget.preference.title}');
              }
            });
            Navigator.pop(context);
          }
        },
      )
    ];

    if (widget.addScanButton) {
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
            if (widget.preference.defaultValue.runtimeType == bool) {
              return SwitchListTile(
                title: Text(widget.preference.title),
                value: snapshot.data,
                secondary: Icon(widget.preference.iconData),
                onChanged: (bool value) {
                  widget.preference.set(value: value).then((bool didSet) {
                    if (widget.preference.onSet != null) {
                      // Trigger rebuild with the newly edited controller.text
                      setState(() {});
                      widget.preference.onSet(
                          context: context, didSet: didSet, value: value);
                    }
                  });
                },
              );
            }
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
                return openPrefDialog(snapshot, context, controller);
              },
              onLongPress: () {
                Fluttertoast.showToast(msg: widget.preference.description);
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}


