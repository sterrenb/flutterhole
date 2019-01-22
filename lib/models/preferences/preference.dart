import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference_form.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Preference {
  final String key;
  final String title;
  final String description;
  final IconData iconData;

  Preference(
      {@required this.key,
      @required this.title,
      @required this.description,
      @required this.iconData});

  static final Future<SharedPreferences> _sharedPreferences =
      SharedPreferences.getInstance();

  Widget _defaultSettingsWidget() {
    return FutureBuilder<String>(
        future: get(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return ListTile(
              leading: Icon(iconData),
              title: Text(title),
              subtitle: Text(snapshot.data),
              onTap: () {
                return _onTap(snapshot, context);
              },
              onLongPress: () {
                Fluttertoast.showToast(msg: description);
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
    ;
  }

  Future _onTap(AsyncSnapshot<String> snapshot, BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _controller = TextEditingController(text: snapshot.data);
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final preferenceForm = PreferenceForm(
            formKey: _formKey,
            controller: _controller,
          );
          return _alertDialog(preferenceForm, context, _controller);
        });
  }

  AlertDialog _alertDialog(PreferenceForm preferenceForm, BuildContext context,
      TextEditingController _controller) {
    return AlertDialog(
      title: Text(title),
      content: preferenceForm,
      actions: <Widget>[
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
              set(_controller.text).then((bool result) {
                print('bool: $result');
              });
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }

  Widget settingsWidget() => _defaultSettingsWidget();

  Future<bool> set(String value) async {
    return (await _sharedPreferences).setString(key, value);
  }

  Future<String> get() async {
    return (await _sharedPreferences).get(key).toString();
  }
}
