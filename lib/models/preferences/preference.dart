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

  Future<SharedPreferences> preferences;

  Preference({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.help,
    @required this.iconData,
    this.onSet,
  }) {
    this.preferences = SharedPreferences.getInstance();
  }

  final defaultValue = '';

  /// The default style for the help widget. This should be added to the global theme someday...
  static final TextStyle helpStyle = TextStyle(color: Colors.black87);

  Future<String> get() async {
    String result = (await preferences).get(id).toString();
    return result;
  }

  Future<bool> set(BuildContext context, {String value}) async {
    if (value == null) {
      value = defaultValue;
    }
    final bool didSave = await (await preferences).setString(id, value);
    return didSave;
  }
}