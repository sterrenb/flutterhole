import 'package:shared_preferences/shared_preferences.dart';

const active = 'configActive';
const all = 'configAll';
const defaultAll = ['Default'];
const defaultActive = 0;

class PiConfig {
  static Future<int> getActive() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int result = preferences.getInt(active);
    return result == null ? defaultActive : result;
  }

  static Future<bool> setActive(int index) async {
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

    print('getAll: $result');
    return result;
  }

  static Future<bool> addConfig(String name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> configs = await getAll();
    if (configs.contains(name)) {
      throw Exception('This name is already used');
    }
    List<String> newConfigs = List.from(configs)..add(name);
    return preferences.setStringList(all, newConfigs);
  }
}
