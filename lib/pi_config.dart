import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';

const active = 'configActive';
const all = 'configAll';
const defaultAll = ['Default'];
const defaultActive = 0;

class PiConfig {
  static Future<int> getActiveIndex() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int result = preferences.getInt(active);
    return result == null ? defaultActive : result;
  }

  static Future<String> getActiveString() async {
    List<String> configs = await getAll();
    return configs.elementAt((await getActiveIndex()));
  }

  static Future<bool> setActiveIndex(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setInt(active, index);
  }

  static Future<bool> switchConfig(
      {@required BuildContext context, int index = 0, bool pop = true}) async {
    await PiConfig.setActiveIndex(index);
    AppState.of(context).resetSleeping();
    AppState.of(context).updateStatus();
    bool isDark = await PreferenceIsDark().get();
    PreferenceIsDark.applyTheme(context, isDark);
    String activeString = await PiConfig.getActiveString();
    Fluttertoast.showToast(msg: 'Switching to $activeString');
    if (pop) Navigator.pop(context);
    return true;
  }

  static Future<List<String>> getAll() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> result = defaultAll;
    try {
      result = preferences.getStringList(all);
      if (result == null) {
        result = defaultAll;
      }
    } catch (e) {
      // return defaultAll;
    }

    return result;
  }

  static Future<bool> hasConfig(String name) async {
    List<String> configs = await getAll();
    return configs.contains(name);
  }

  static Future<int> setConfig(String name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> configs = await getAll();
    if (await hasConfig(name)) {
      throw Exception('This name is already used');
    }
    List<String> newConfigs = List.from(configs)..add(name);
    print('newConfigs after setConfig: ${newConfigs.toString()}');
    await preferences.setStringList(all, newConfigs);
    return (await getAll()).length - 1;
  }

  static Future<bool> updateActiveConfig(String name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> configs = await getAll();
    if (configs.contains(name) && (await getActiveString()) != name) {
      throw Exception('This config is already active');
    }

    final int index = await getActiveIndex();
    configs[index] = name;
    return preferences.setStringList(all, configs);
  }

  static Future<bool> removeActiveConfig() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final int activeIndex = await getActiveIndex();
    List<String> configs = await getAll();
    print('configs: ${configs.toString()}');
    print('activeIndex: ${activeIndex.toString()}');
    print('all: ${await getAll()}');

    if (configs.length == 1) {
      Fluttertoast.showToast(msg: 'No other configurations available');
      return false;
    }

    List<String> newConfigs = List.from(configs)
      ..removeAt(activeIndex);

    // skip this loop if we can simply switch back to the only configuration left
    if ((activeIndex == 1 && configs.length == 2)) {
      // else, move the contents down by 1 index
      for (int i = configs.length - 1; i > activeIndex; i --) {
        // TODO well...
      }
    }


    print('newConfigs: ${newConfigs.toString()}');
    await preferences.setStringList(all, newConfigs);
    return true;
  }
}
