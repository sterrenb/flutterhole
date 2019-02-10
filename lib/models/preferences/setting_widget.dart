import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/models/dashboard/scan_button.dart';
import 'package:sterrenburg.github.flutterhole/models/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/models/preferences/preference_form.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingWidget extends StatefulWidget {
  final Preference preference;
  final bool addScanButton;
  final Type type;

  const SettingWidget({Key key,
    @required this.preference,
    this.type = String,
    this.addScanButton = false})
      : super(key: key);

  @override
  SettingWidgetState createState() {
    return new SettingWidgetState();
  }
}

class SettingWidgetState extends State<SettingWidget> {
  Future onHelpTap(BuildContext context, Widget help) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.preference.title),
            content: help,
          );
        });
  }

  Future onPrefTap(AsyncSnapshot<dynamic> snapshot, BuildContext context,
      TextEditingController controller) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertPrefDialog(
              PreferenceForm(
                  formKey: formKey, controller: controller, type: widget.type),
              context,
              controller);
        });
  }

  AlertDialog alertPrefDialog(PreferenceForm preferenceForm,
      BuildContext context, TextEditingController controller) {
    List<Widget> actions = [
      FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      FlatButton(
        child: Text('OK'),
        onPressed: () {
          if (preferenceForm.formKey.currentState.validate()) {
            widget.preference
                .set(value: controller.value.text)
                .then((bool didSet) {
              if (didSet) {
                setState(() {});
                if (widget.preference.onSet != null) {
                  // Trigger rebuild with the newly edited controller.text

                  widget.preference.onSet(
                      context: context,
                      didSet: didSet,
                      value: controller.value.text);
                }
              } else {
                print('non didSet...');
              }
            });
            Navigator.pop(context);
          }
        },
      )
    ];

    if (widget.addScanButton) {
      actions.insert(0, ScanButton(controller: controller));
    }

    return AlertDialog(
      title: Text(widget.preference.title),
      content: preferenceForm,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: widget.preference.get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            // TODO this looks terrible
            if (widget.type == bool) {
              return SwitchListTile(
                title: Text(widget.preference.title),
                value: snapshot.data,
                secondary: Icon(widget.preference.iconData),
                onChanged: (bool value) {
                  widget.preference
                      .set(value: value)
                      .then((bool didSet) {
                    if (widget.preference.onSet != null) {
                      // Trigger rebuild with the newly edited controller.text
                      setState(() {});
                      widget.preference.onSet(
                          context: context, didSet: didSet, value: value);
                    }
                  });
//                  Brightness brightness =
//                      value ? Brightness.dark : Brightness.light;
//                  DynamicTheme.of(context).setBrightness(brightness);
//                  setState(() {});
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
                    onPressed: () => onHelpTap(context, widget.preference.help),
                  )
                ],
              ),
              subtitle: Text(controller.text),
              onTap: () {
                return onPrefTap(snapshot, context, controller);
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
