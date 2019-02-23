import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';

class PiConfig {
  static const String activeKey = 'configActive';
  static const String allKey = 'configAll';
  static const List<String> defaultAll = ['Default'];
  static const int defaultActive = 0;

  Future<SharedPreferences> _preferences;

  PiConfig() {
    this._preferences = SharedPreferences.getInstance();
  }

  Future<int> getActiveIndex() async {
    final preferences = await _preferences;
    final index = preferences.getInt(activeKey);
    return (index == null) ? defaultActive : index;
  }

  Future<List<String>> getAll({String key = allKey}) async {
    return _preferences.then((preferences) {
      return preferences.getStringList(key) ?? defaultAll;
    });
  }

  Future<String> getActiveString() async {
    final int index = await getActiveIndex();
    final List<String> all = await getAll();
    return all.elementAt((index));
  }

  Future<bool> setActiveIndex(int index) async {
    assert(index != null);
    final SharedPreferences preferences = await _preferences;
    final bool didSet = await preferences.setInt(activeKey, index);
    return (didSet == null) ? false : didSet;
  }

  Future<bool> switchConfig(
      {@required BuildContext context, int index = 0, bool pop = true}) async {
    final bool didSet = await setActiveIndex(index);
    if (!didSet) {
      if (pop) Navigator.pop(context);
      return false;
    }

    AppState.of(context).resetSleeping();
    AppState.of(context).updateStatus();
    bool isDark = await PreferenceIsDark().get();
    PreferenceIsDark.applyTheme(context, isDark);
    String activeString = await getActiveString();
    Fluttertoast.showToast(msg: 'Switching to $activeString');
    // TODO move up pop
    if (pop) Navigator.pop(context);
    return true;
  }

  Future<int> setConfig(String name) async {
    final preferences = await _preferences;
    final configs = await getAll();
    name = name.trim();
    if (configs.contains(name)) {
      throw Exception('This name already exists');
    }
    List<String> newConfigs = List.from(configs)..add(name);
    final didSet = await preferences.setStringList(allKey, newConfigs);
    if (!didSet) {
      throw Exception('Failed to set config');
    }

    return newConfigs.length - 1;
  }

  Future<bool> updateActiveConfig(String name) async {
    return _preferences.then((preferences) =>
        getAll().then((configs) {
          if (configs.contains(name)) {
            getActiveString().then((activeString) {
              if (name == activeString) {
                return true;
              }
              throw Exception('This configuration already exists');
            });
          }

          getActiveIndex().then((activeIndex) {
            List<String> newConfigs = List.from(configs)
              ..removeAt(activeIndex)
              ..insert(activeIndex, name);
            return preferences.setStringList(allKey, newConfigs);
          });
        }));
  }
}
