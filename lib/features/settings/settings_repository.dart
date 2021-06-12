import 'dart:convert';

import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

class SettingsRepository {
  const SettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  void info() {
    _preferences.setString('teehee', 'myVal');
    final j = _preferences.getString(123.toString());
    if (j != null) {
      print(j);
      final m = jsonDecode(j);
      print(m);
      final p = PiModel.fromJson(m);
      print(p);
    }
  }

  Pi _single(int id) {
    final String? jsonString = _preferences.getString(id.toString());
    if (jsonString == null) throw IndexError(id, _preferences.getKeys());

    final model = PiModel.fromJson(jsonDecode(jsonString));
    return model.entity;
  }

  List<Pi> allPis() {
    final piIds =
        _preferences.getKeys().map((e) => int.tryParse(e)).whereType<int>();
    final pis = piIds.map((id) => _single(id)).toList();
    print(pis);

    if (pis.isEmpty) return [PiModel.initial().entity];
    // .copyWith(
    // primaryColor: Colors.accents
    //     .elementAt(Random().nextInt(Colors.accents.length))
    //     .value)
    pis.sort((a, b) => a.id - b.id);
    return pis;
  }

  int activePiId() => _preferences.getInt("active") ?? 0;

  Future<void> setActivePiId(int id) => _preferences.setInt("active", id);

  Future<void> clear() => _preferences.clear();

  Future<void> savePi(Pi pi) async {
    print(pi.title);
    final model = PiModel(
      id: pi.id,
      title: pi.title,
      description: pi.description,
      primaryColor: pi.primaryColor.value,
      accentColor: pi.accentColor.value,
      baseUrl: pi.baseUrl,
      useSsl: pi.useSsl,
      apiPath: pi.apiPath,
      apiPort: pi.apiPort,
      apiToken: pi.apiToken,
      apiTokenRequired: pi.apiTokenRequired,
      allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
      basicAuthenticationUsername: pi.basicAuthenticationUsername,
      basicAuthenticationPassword: pi.basicAuthenticationPassword,
      proxyUrl: pi.proxyUrl,
      proxyPort: pi.proxyPort,
    );

    print(model);
    final j = jsonEncode(model);
    print('JSON:');
    print(j);
    await _preferences.setString(pi.id.toString(), j);
  }
}
