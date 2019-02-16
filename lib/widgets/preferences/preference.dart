import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_hostname.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_port.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_token.dart';

const String configNames = 'configNames';
const String defaultConfigName = 'Default';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
abstract class Preference {
  /// The unique identifier used to store the preference.
  final String id;

  /// The human friendly title.
  final String title;

  /// The human friendly description.
  final String description;

  /// The help widget that a user can select and view separately.
  final Widget help;

  /// The leading material icon.
  ///
  /// ```dart
  /// iconData = Icons.home;
  /// ```
  IconData iconData;

  /// The callback for the save action.
  final Function({BuildContext context, bool didSet, dynamic value}) onSet;

  Future<SharedPreferences> _preferences;

  Preference({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.help,
    @required this.iconData,
    this.onSet,
  }) {
    this._preferences = SharedPreferences.getInstance();
  }

  final dynamic defaultValue = '';

  /// The default style for the help widget. This should be added to the global theme someday...
  static final TextStyle helpStyle = TextStyle(color: Colors.black87);

  final log = Logger('Preference');

  static Future<bool> resetAll() async {
    await PreferenceHostname().set();
    await PreferencePort().set();
    await PreferenceIsDark().set();
    await PreferenceToken().set();
//    await resetConfigs();
    return true;
  }

  Future<String> _getIdWithConfig() async {
    String idWithConfig = id + ((await PiConfig.getActiveIndex()).toString());
//    log.info('getIdWithConfig: ' + idWithConfig);
    return idWithConfig;
  }

  Future<dynamic> get() async {
    String result = (await _preferences).get(await _getIdWithConfig());
    return result == null ? defaultValue : result;
  }

  Future<bool> set({dynamic value}) async {
    if (value == null) {
      value = defaultValue;
    }

    final bool didSave = await (await _preferences)
        .setString(await _getIdWithConfig(), value.toString());
    return didSave;
  }
}

class PreferenceInt extends Preference {
  final int defaultValue = 0;

  PreferenceInt({String id,
    String title,
    String description,
    Widget help,
    IconData iconData,
    Function({BuildContext context, bool didSet, dynamic value}) onSet})
      : super(
      id: id,
      title: title,
      description: description,
      help: help,
      iconData: iconData,
      onSet: onSet);

  @override
  Future<dynamic> get() async {
    int result = (await _preferences).getInt(await _getIdWithConfig());
    return result == null ? defaultValue : result;
  }

  @override
  Future<bool> set({dynamic value}) async {
    int typedValue;
    if (value == null) {
      typedValue = defaultValue;
    }
    if (value.runtimeType == String) {
      typedValue = int.parse(value);
    }

    final bool didSave =
    await (await _preferences).setInt(await _getIdWithConfig(), typedValue);
    return didSave;
  }
}

class PreferenceBool extends Preference {
  final bool defaultValue = false;

  PreferenceBool({String id,
    String title,
    String description,
    Widget help,
    IconData iconData,
    Function({BuildContext context, bool didSet, dynamic value}) onSet})
      : super(
      id: id,
      title: title,
      description: description,
      help: help,
      iconData: iconData,
      onSet: onSet);

  @override
  Future<dynamic> get() async {
    bool result = (await _preferences).getBool(await _getIdWithConfig());
    print('$title get: ${result.toString()}');
    return result == null ? defaultValue : result;
  }

  @override
  Future<bool> set({dynamic value}) async {
    bool typedValue = value;
    if (value == null) {
      typedValue = defaultValue;
    }
    if (value.runtimeType == String) {
      typedValue = bool.fromEnvironment(value);
    }

    final bool didSave = await (await _preferences)
        .setBool(await _getIdWithConfig(), typedValue);
    return didSave;
  }
}
