import 'package:shared_preferences/shared_preferences.dart';

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
    await preferences.setStringList(all, newConfigs);
    return (await getAll()).length - 1;
  }

  static Future<bool> updateActiveConfig(String name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> configs = await getAll();
    if (configs.contains(name) && (await getActiveString()) != name) {
      throw Exception('This name is already used');
    }

    final int index = await getActiveIndex();
    configs[index] = name;
    return preferences.setStringList(all, configs);
  }
}
