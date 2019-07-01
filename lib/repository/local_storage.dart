import 'package:fimber/fimber.dart';
import 'package:flutterhole_again/model/pihole.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The key where a String with the active pihole preference is saved.
const String _piholeActiveKey = 'pihole_active';

/// The prefix used for all pihole preferences.
const String piholePrefix = 'pihole_user_';

/// Singleton for saving and loading shared preferences.
class LocalStorage {
  static LocalStorage _instance;
  static SharedPreferences _preferences;

  Map<String, Pihole> _cache = {};

  Map<String, Pihole> get cache => _cache;

  Pihole get active => _cache[_preferences.getString(_piholeActiveKey)];

  String activeKey;

  final logger = FimberLog('LocalStorage');

  static Future<LocalStorage> getInstance() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
      await _preferences.reload();
    }

    if (_instance == null) {
      _instance = LocalStorage();
      await _instance.init();
    }

    return _instance;
  }

  Future<void> init() async {
    Set<String> keys = _preferences.getKeys();

    print('all keys: ${keys.toString()}');
    keys.retainWhere((String key) => key.startsWith(piholePrefix));

    keys.forEach((String key) {
      if (key.endsWith(titleKey)) {
        String piholeKey = key.substring(
            piholePrefix.length, key.length - titleKey.length - 1);
        List<String> piholeKeys = keys.toList()
          ..retainWhere((String key) => key.contains(piholeKey));
        print('pihole keys: $piholeKeys');

        _cache[piholeKey] = Pihole(
          title: _preferences.get(
              piholeKeys.firstWhere((String key) => key.contains(titleKey))),
          host: _preferences.get(
              piholeKeys.firstWhere((String key) => key.contains(hostKey))),
          port: _preferences.get(
              piholeKeys.firstWhere((String key) => key.contains(portKey))),
          auth: _preferences.get(
              piholeKeys.firstWhere((String key) => key.contains(authKey))),
        );

        print('cache size: ${_cache.length}');
      }
    });

    print('leftover keys: ${keys.toString()}');
  }

  static Future<void> reset() async {
    await _preferences?.clear();
    _preferences = null;
    _instance = null;
  }

  Future<void> save(Pihole pihole) async {
    if (_cache.containsKey(pihole.key)) {
      throw Exception('key is already in use');
    }
    final map = pihole.toJson();

    List<Future<void>> futures = [];

    map.forEach((String key, dynamic value) {
      futures.add(_set('$piholePrefix${pihole.key}_', key, value));
    });

    await Future.wait(futures);

    _cache[pihole.key] = pihole;
  }

  Future<void> activate(String key) async {
    await _preferences.setString(_piholeActiveKey, key);
  }

  Future<bool> _set(String prefix, String key, dynamic value) async {
    logger.i('set key: $prefix$key value: $value');
    if (value is String) {
      return _preferences.setString('$prefix$key', value);
    }
    if (value is bool) {
      return _preferences.setBool('$prefix$key', value);
    }
    if (value is int) {
      return _preferences.setInt('$prefix$key', value);
    }
    if (value is double) {
      return _preferences.setDouble('$prefix$key', value);
    }
    if (value is List<String>) {
      return _preferences.setStringList('$prefix$key', value);
    }

    throw Exception('unknown value type ${value.runtimeType}');
  }
}
