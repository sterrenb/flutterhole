import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutterhole/model/pihole.dart';

import 'globals.dart';

const String piholePrefix = 'pihole_';
const String activePiholeKey = 'active_pihole';

class SecureStore {
  SecureStore(this.storage, [this.map]);

  Pihole _active;

  Pihole get active {
    return _active;
  }

  Map<String, Pihole> piholes = {};

  Map<String, String> map;

  final FlutterSecureStorage storage;

  Future<String> get(String key) async {
    if (map != null) return map[key];

    return storage.read(key: '$piholePrefix$key');
  }

  Future<void> _updateActive() async {
    final String activeTitleLoaded = await storage.read(key: activePiholeKey);

    if (activeTitleLoaded != null && piholes.containsKey(activeTitleLoaded)) {
      return activate(piholes[activeTitleLoaded]);
    }

    if (piholes.isNotEmpty) {
      Globals.tree.log('SecureStore',
          'active not found in cache, activating first pihole (out of ${piholes
              .length} piholes)');
      return activate(piholes.values.first);
    }

    Globals.tree.log('SecureStore', 'no configurations found, using default');
    return activate(Pihole());
  }

  Future<void> activate(Pihole pihole) async {
    if (!piholes.containsValue(pihole)) {
      Globals.tree
          .log('SecureStore', 'using uncached configuration `${pihole.title}`');
    }

    await storage.write(key: activePiholeKey, value: pihole.title);
    piholes[pihole.title] = pihole;
    _active = pihole;
  }

  Future<void> deleteAll() async {
    await storage.deleteAll();
    piholes.clear();
    _active = null;
  }

  Future<void> reload() async {
    piholes.clear();

    map = await storage.readAll();

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
      final String useSSLString = await get('${title}_$useSSLKey');
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
        useSSL:
        useSSLString == null ? false : useSSLString.toLowerCase() == 'true',
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
      try {
        return storage.delete(key: '$piholePrefix${pihole.title}_$key');
      } catch (e) {
        Globals.tree.log('SecureStore', 'remove failed: ${e.toString()}');
      }
    });

    piholes.remove(pihole.title);
  }

  Future<void> add(Pihole pihole, {bool allowOverride = false}) async {
    if (!allowOverride && piholes.containsValue(pihole)) {
      throw Exception(
          '${pihole
              .title} already present - if this was intended, set `allowOverride = true`');
    }

    final map = pihole.toJson();

    await Future.forEach(map.keys, (key) async {
      final String value = map[key];
      try {
        return storage.write(
            key: '$piholePrefix${pihole.title}_$key', value: value);
      } catch (e) {
        Globals.tree.log('SecureStore', 'add failed: ${e.toString()}');
      }
    });

    piholes.addAll({pihole.title: pihole});
  }

  Future<void> update(Pihole original, Pihole update) async {
    if (!piholes.containsKey(original.title)) {
      Globals.tree.log(
          'SecureStore', 'the original Pihole is not yet present during update',
          tag: 'warning');
    }

    if (update == original) return;

    final bool originalIsActive = (original == active);

    if (original.title != update.title && piholes.containsKey(update.title)) {
      throw Exception('${update.title} already present');
    }

    await remove(original);
    await add(update);

    if (originalIsActive) {
      await activate(update);
    }
  }
}
