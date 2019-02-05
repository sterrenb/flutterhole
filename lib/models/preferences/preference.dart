import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
abstract class Preference {
  /// The unique identifier used to store the preference.
  final String id;

  /// The human friendly title.
  final String title;

  // The human friendly description.
  final String description;

  // The help widget that a user can select and view separately.
  final Widget help;

  // The callback for the save action.
  final Function(bool, BuildContext) onSet;
  final IconData iconData;

  Preference({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.help,
    @required this.iconData,
    this.onSet,
  });

  /// The default style for the help widget. This should be added to the global theme someday...
  static final TextStyle helpStyle = TextStyle(color: Colors.black87);

  static final Future<SharedPreferences> _sharedPreferences =
  SharedPreferences.getInstance();

  Future<bool> set(String value, BuildContext context) async {
    print('setting sharedpref: $id => $value');
    final bool didSave = await (await _sharedPreferences).setString(id, value);
    return didSave;
  }

  Future<bool> setBool(bool value, BuildContext context) async {
    print('setting sharedpref: $id => $value');
    final bool didSave = await (await _sharedPreferences).setBool(id, value);
    return didSave;
  }

  Future<String> get() async {
    String result = (await _sharedPreferences).get(id).toString();
    return result;
  }

  Future<bool> getBool() async {
    bool result = (await _sharedPreferences).getBool(id);
    return result;
  }
}
