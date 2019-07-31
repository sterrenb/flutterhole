import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterhole/model/pihole.dart';

import 'globals.dart';

const String piholePrefix = 'pihole_';
const String activePrefix = 'active_pihole';

class SecureStore {
  SecureStore([this.map]);

  Pihole _active;

  Pihole get active {
    Globals.tree.log('SecureStore', 'securestore active: $_active');
    return _active;
  }

  Map<String, Pihole> piholes = {};

  Map<String, String> map;

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String> get(String key) async {
    if (map != null) return map[key];

    return _storage.read(key: '$piholePrefix$key');
  }

  Future<void> _updateActive() async {
    final String activeTitle = await _storage.read(key: activePrefix);

    if (activeTitle != null) {
      if (piholes.containsKey(activeTitle)) {
        _active = piholes[activeTitle];
      } else {
        Globals.tree.log('SecureStore',
            'active not found in cache, activating first pihole (out of ${piholes.length} piholes)');
        await activate(piholes.values.first);
      }
    } else {
      Globals.tree.log('SecureStore',
          'no active found, activating first pihole (out of ${piholes.length} piholes)');
      await activate(piholes.values.first);
    }
  }

  Future<void> activate(Pihole pihole) async {
    assert(piholes.containsValue(pihole));

    await _storage.write(key: activePrefix, value: pihole.title);
    _active = pihole;
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
    piholes.clear();
    _active = null;
  }

  Future<void> reload() async {
    piholes.clear();

    map = await _storage.readAll();

    // retain only pihole pairs
    map.removeWhere((key, value) {
      return !key.startsWith(piholePrefix);
    });

    // alter keys to start with pihole configuration name
    map = map.map((key, value) => MapEntry<String, String>(
          key.replaceFirst(piholePrefix, ''),
          value,
        ));

    final Set<String> titles =
        map.keys.map((key) => key.split('_').first).toSet();

    await Future.forEach(titles, (title) async {
      final String titleString = await get('${title}_$titleKey');
      final String hostString = await get('${title}_$hostKey');
      final String portString = await get('${title}_$portKey');
      final String allowSelfSignedString =
          await get('${title}_$allowSelfSignedKey');
      final String authString = await get('${title}_$authKey');
      final String apiPathString = await get('${title}_$apiPathKey');

      final String proxyUsernameString =
          await get('${title}_$proxyKey$usernameKey');
      final String proxyHostString = await get('${title}_$proxyKey$hostKey');
      final String proxyPortString = await get('${title}_$proxyKey$portKey');
      final String proxyPasswordString =
          await get('${title}_$proxyKey$passwordKey');
      piholes[title] = Pihole(
        title: titleString,
        host: hostString,
        port: portString == null ? 80 : int.parse(portString),
        apiPath: apiPathString,
        auth: authString,
        allowSelfSigned: allowSelfSignedString == null
            ? false
            : allowSelfSignedString.toLowerCase() == 'true',
        proxy: Proxy(
          host: proxyHostString,
          port: proxyPortString == null ? 8080 : int.parse(proxyPortString),
          username: proxyUsernameString,
          password: proxyPasswordString,
        ),
      );
    });

    await _updateActive();
  }

  Future<void> remove(Pihole pihole) async {
    final map = pihole.toJson();

    await Future.forEach(map.keys, (key) async {
      Globals.tree
          .log('SecureStore', 'delete $piholePrefix${pihole.title}_$key');
      try {
        return _storage.delete(key: '$piholePrefix${pihole.title}_$key');
      } catch (e) {
        Globals.tree.log('SecureStore', 'remove failed: ${e.toString()}');
      }
    });

    piholes.remove(pihole);
  }

  Future<void> add(Pihole pihole) async {
    final map = pihole.toJson();

    await Future.forEach(map.keys, (key) async {
      final String value = map[key];
      Globals.tree
          .log('SecureStore', 'add $piholePrefix${pihole.title}_$key: $value');

      try {
        return _storage.write(
            key: '$piholePrefix${pihole.title}_$key', value: value);
      } catch (e) {
        Globals.tree.log('SecureStore', 'remove failed: ${e.toString()}');
      }
    });

    piholes.addAll({pihole.title: pihole});
  }

  Future<void> update(Pihole original, Pihole update) async {
    if (update == original) return;

    final bool originalIsActive = (original == active);

    await remove(original);
    await add(update);

    if (originalIsActive) {
      await activate(update);
    }
  }
}
