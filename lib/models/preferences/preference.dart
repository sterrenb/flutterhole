import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/scan_button.dart';
import 'package:flutter_hole/models/preferences/preference_form.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
abstract class Preference {
  /// The unique identifier used to store the preference.
  final String key;

  /// The human friendly title.
  final String title;

  // The human friendly description.
  final String description;

  // The help widget that a user can select and view separately.
  final Widget help;

  // The callback for the save action.
  final Function(bool, BuildContext) onSet;
  final IconData iconData;

  final bool addScanButton;

  Preference({
    @required this.key,
    @required this.title,
    @required this.description,
    @required this.help,
    @required this.iconData,
    this.addScanButton = false,
    this.onSet,
  });

  /// The default style for the help widget. This should be added to the global theme someday...
  static final TextStyle helpStyle = TextStyle(color: Colors.black87);

  static final Future<SharedPreferences> _sharedPreferences =
  SharedPreferences.getInstance();

  Widget _defaultSettingsWidget() {
    return FutureBuilder<String>(
        future: get(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            final controller = TextEditingController(text: snapshot.data);
            return ListTile(
              leading: Icon(iconData),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(title),
                  IconButton(
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.grey,
                      size: 16.0,
                    ),
                    onPressed: () => _onHelpTap(context, help),
                  )
                ],
              ),
              subtitle: Text(controller.text),
              onTap: () {
                return _onPrefTap(snapshot, context, controller);
              },
              onLongPress: () {
                Fluttertoast.instance.showToast(msg: description);
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  Future _onPrefTap(AsyncSnapshot<String> snapshot, BuildContext context,
      TextEditingController controller) {
    final _formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final preferenceForm = PreferenceForm(
            formKey: _formKey,
            controller: controller,
          );
          return _alertPrefDialog(preferenceForm, context, controller, onSet);
        });
  }

  Future _onHelpTap(BuildContext context, Widget help) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: help,
          );
        });
  }

  AlertDialog _alertPrefDialog(PreferenceForm preferenceForm,
      BuildContext context, TextEditingController controller, Function onSet) {
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
            set(controller.text, context).then((bool didSet) {
              if (onSet != null) {
                onSet(didSet, context);
              }
            });
            Navigator.pop(context);
          }
        },
      )
    ];

    if (addScanButton) {
      actions.insert(0, ScanButton(controller: controller));
    }

    return AlertDialog(
      title: Text(title),
      content: preferenceForm,
      actions: actions,
    );
  }

  Widget settingsWidget() => _defaultSettingsWidget();

  Future<bool> set(String value, BuildContext context) async {
    print('setting sharedpref: $key => $value');
    final bool didSave = await (await _sharedPreferences).setString(key, value);
    return didSave;
  }

  Future<bool> setBool(bool value, BuildContext context) async {
    print('setting sharedpref: $key => $value');
    final bool didSave = await (await _sharedPreferences).setBool(key, value);
    return didSave;
  }

  Future<String> get() async {
    String result = (await _sharedPreferences).get(key).toString();
    return result;
  }

  Future<bool> getBool() async {
    bool result = (await _sharedPreferences).getBool(key);
    return result;
  }
}
