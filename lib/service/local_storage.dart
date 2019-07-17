import 'package:fimber/fimber.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The key where a String with the active pihole preference is saved.
const String _piholeActiveKey = 'active_pihole';

/// The prefix used for all pihole preferences.
const String piholePrefix = 'pihole_user_';

/// Singleton for saving and loading shared preferences.
class LocalStorage {
  static LocalStorage _instance;
  static SharedPreferences _preferences;

  Map<String, Pihole> _cache = {};

  Map<String, Pihole> get cache => _cache;

  Pihole active() {
    final String key = _preferences.getString(_piholeActiveKey);
    return _cache[key];
  }

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
    _cache = {};
    await _preferences.reload();
    Set<String> keys = _preferences.getKeys();

    keys.retainWhere((String key) => key.startsWith(piholePrefix));

    keys.forEach((String key) {
      if (key.endsWith(titleKey)) {
        String piholeKey = key.substring(
            piholePrefix.length, key.length - titleKey.length - 1);
        List<String> piholeKeys = keys.toList()
          ..retainWhere((String key) => key.contains(piholeKey));

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
      }
    });
  }

  static Future<void> clear() async {
    await _preferences?.clear();
    _instance._cache = {};
  }

  /// Resets all preference keys and adds a default Pihole configuration.
  Future<void> reset() async {
    await clear();
    final pihole = Pihole();
    await _instance.init();
    await _instance.add(pihole);
    await _instance.activate(pihole);
  }

  Future<bool> remove(Pihole pihole) async {
    List<Future<void>> futures = [];

    if (!_cache.containsKey(pihole.localKey)) {
      logger.w('cannot remove ${pihole.localKey}: key not found');
      return false;
    }

    final map = pihole.toJson();
    map.forEach((String key, _) {
      futures.add(_remove('$piholePrefix${pihole.localKey}_', key));
    });

    await Future.wait(futures);

    _cache.remove(pihole.localKey);

    if (_cache.isEmpty) {
      await add(Pihole());
    }

    return true;
  }

  Future<bool> add(Pihole pihole, {bool override = false}) async {
    List<Future<void>> futures = [];

    if (_cache.containsKey(pihole.localKey) && !override) {
      Fimber.w(
          'cannot add ${pihole.title}: key ${pihole.localKey} already in use');
      return false;
    }

    final map = pihole.toJson();
    map.forEach((String key, dynamic value) {
      futures.add(_set('$piholePrefix${pihole.localKey}_', key, value));
    });

    await Future.wait(futures);

    _cache[pihole.localKey] = pihole;

    return true;
  }

  Future<void> update(Pihole original, Pihole update) async {
    if (cache.containsKey(update.localKey) &&
        update.localKey != original.localKey) {
      throw Exception('cannot update: key ${update.localKey} already in use');
    }

    final originalIsActive = active() == original;

    await add(update, override: true);

    if (originalIsActive) {
      activate(update);
    }

    if (update.localKey != original.localKey) {
      await remove(original);
    }
  }

  Future<void> activate(Pihole pihole) async {
    if (!_cache.containsKey(pihole.localKey)) {
      throw Exception('cannot activate ${pihole.title}: key not found');
    }

    await _preferences.setString(_piholeActiveKey, pihole.localKey);
    logger.i('activated ${pihole.localKey}');
  }

  Future<bool> _remove(String prefix, String key) async {
    logger.i('remove key: $prefix$key');
    return _preferences.remove('$prefix$key');
  }

  Future<bool> _set(String prefix, String key, dynamic value) async {
    if (value == _preferences.get('$prefix$key')) {
      return false;
    }

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

    throw Exception('unsupported value type ${value.runtimeType}');
  }
}
